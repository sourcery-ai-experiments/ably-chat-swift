import Ably


public struct MessageEventPayloadWrapper: Hashable, Sendable {
    let id: String
    let listener: @Sendable (MessageEventPayload) -> Void

    // Hashable conformance via the id
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: MessageEventPayloadWrapper, rhs: MessageEventPayloadWrapper) -> Bool {
        return lhs.id == rhs.id
    }
    
    public init(id: String, listener: @Sendable @escaping (MessageEventPayload) -> Void) {
        self.id = id
        self.listener = listener
    }
}

typealias fromSerial = String
typealias MessageListeners = [MessageEventPayloadWrapper: fromSerial]


public struct MessageEventPayload: Sendable, Hashable {
    
    /**
     * The type of the message event.
     */
    let type: MessageEvents

    /**
     * The message that was received.
     */
    public let message: Message
}


actor DefaultMessages: Messages, HandlesDiscontinuity {
    private let roomID: String
    internal var channel: (any RealtimeChannelProtocol)?
    private let chatAPI: ChatAPI
    private let clientID: String
    private var listenerSubscriptionPoints: MessageListeners = [:]

    private let lock = NSLock()
    private let realtime: RealtimeClient
    

    init(chatAPI: ChatAPI, realtime: RealtimeClient, roomID: String, clientID: String) {
        self.chatAPI = chatAPI
        self.roomID = roomID
        self.clientID = clientID
        self.realtime = realtime
        
        Task {
            await initChannel()
        }
    }
    
    private func initChannel() async {
        do {
            for try await channel in makeChannel(roomId: roomID, realtime: realtime) {
                self.channel = channel
            }
        } catch {
            fatalError("Failed to create channel: \(error)")
        }
    }
    
    func removeSubscriptionPoint(listener: MessageEventPayloadWrapper) {
        listenerSubscriptionPoints.removeValue(forKey: listener)
    }
    
    func subscribe(bufferingPolicy: BufferingPolicy, listener: MessageEventPayloadWrapper) async throws -> MessageSubscriptionResponse {
        let timeSerial = try await resolveSubscriptionStart()
        listenerSubscriptionPoints[listener] = timeSerial
        
        channel?.subscribe(MessageEvents.created.rawValue, callback: { message in
            Task {

                guard let data = message.data as? Dictionary<String, Any>,
                      let text = data["text"] as? String else {
                    return
                }

                guard let timeSerial = try message.extras?.toJSON()["timeserial"] as? String else {
                    return
                }
                
                listener.listener(
                    .init(type: .created,
                          message: .init(timeserial: timeSerial,
                                         clientID: message.clientId,
                                         roomID: self.roomID,
                                         text: text,
                                         createdAt: message.timestamp,
                                         metadata: .init(),
                                         headers: .init())
                         )
                )
            }
        })
        
        return MessageSubscriptionWrapper { [self] in
            await removeSubscriptionPoint(listener: listener)
        } getPreviousMessages: { [self] in
            try await getBeforeSubscriptionStart(listener: listener, params: .init())
        }
    }
    
    func get(options: QueryOptions) async throws -> any PaginatedResult<Message> {
        try await chatAPI.getMessages(roomId: roomID, params: options)
    }
    
    func send(params: SendMessageParams) async throws -> Message {
        try await chatAPI.sendMessage(roomId: roomID, params: params)
    }
    
    nonisolated func subscribeToDiscontinuities() -> Subscription<ARTErrorInfo> {
        fatalError()
    }

    nonisolated func discontinuityDetected(reason: ARTErrorInfo?) {
        print("Discontinuity detected: \(reason ?? .createUnknownError())")
    }
    
    private func getBeforeSubscriptionStart(listener: MessageEventPayloadWrapper, params: QueryOptions) async throws -> any PaginatedResult<Message> {
        guard let subscriptionPoint = listenerSubscriptionPoints[listener] else {
            throw ARTErrorInfo.create(
                withCode: 40000,
                status: 400,
                message: "cannot query history; listener has not been subscribed yet"
            )
        }

        // Check the end time does not occur after the fromSerial time
        let parseSerial = try? DefaultTimeserial.calculateTimeserial(from: subscriptionPoint)
        if let end = params.end, end > parseSerial?.timestamp ?? 0 {
            throw ARTErrorInfo.create(
                withCode: 40000,
                status: 400,
                message: "cannot query history; end time is after the subscription point of the listener"
            )
        }

        // Query messages from the subscription point to the start of the time window
        return try await chatAPI.getMessages(roomId: roomID, params: .init(limit: 5))
    }

    private func makeChannel(roomId: String, realtime: RealtimeClient) -> AsyncThrowingStream<any RealtimeChannelProtocol, Error> {

        return AsyncThrowingStream { stream in
            channel = getChannel(messagesChannelName(roomId: roomId), realtime: realtime)
            guard let channel else {
                stream.finish(throwing: ARTErrorInfo.createUnknownError())
                return
            }

            channel.on(.attached) { [self] stateChange in
                Task {
                    do {
                        try await handleAttach(fromResume: stateChange.resumed)
                        stream.yield(channel)
                        return
                    } catch {
                        stream.finish(throwing: error)
                        return
                    }
                }
            }
            
            channel.on(.update) { [self] stateChange in
                if stateChange.current == .attached && stateChange.previous == .attached {
                    Task {
                        do {
                            try await handleAttach(fromResume: stateChange.resumed)
                            stream.yield(channel)
                            return
                        } catch {
                            stream.finish(throwing: error)
                            return
                        }
                    }
                }
            }
        }
    }
    
    private func handleAttach(fromResume: Bool) async throws {
        // Do nothing if we have resumed as there is no discontinuity in the message stream
        if fromResume { return }

        // Reset subscription points for all listeners
        do {
            let newSubscriptionStartResolver = try await self.subscribeAtChannelAttach()
            
            for listener in listenerSubscriptionPoints.keys {
                listenerSubscriptionPoints[listener] = newSubscriptionStartResolver
            }
        } catch {
            throw error
        }
    }
    
    private func resolveSubscriptionStart() async throws -> fromSerial {
        let channelWithProperties = try await getChannelProperties()

        // If we are attached, resolve with the channelSerial
        if channelWithProperties.channel?.state == .attached {
            if let channelSerial = channelWithProperties.properties.channelSerial {
                return channelSerial
            } else {
                throw ARTErrorInfo.create(withCode: 40000, status: 400, message: "channel is attached, but channelSerial is not defined")
            }
        }

        return try await subscribeAtChannelAttach()
    }

    private func getChannelProperties() async throws -> (channel: (any RealtimeChannelProtocol)?, properties: (attachSerial: String?, channelSerial: String?)) {

        // Return the channel with the properties as a tuple
        let properties = (
            attachSerial: channel?.properties.attachSerial,
            channelSerial: channel?.properties.channelSerial
        )

        return (channel, properties)
    }

    private func subscribeAtChannelAttach() async throws -> String {
        let channelWithProperties = try await getChannelProperties()

        // If the state is already 'attached', return the attachSerial immediately
        if channelWithProperties.channel?.state == .attached {
            if let attachSerial = channelWithProperties.properties.attachSerial {
                return attachSerial
            } else {
                throw ARTErrorInfo.create(withCode: 40000, status: 400, message: "Channel is attached, but attachSerial is not defined")
            }
        }

        // Wait for the channel to be 'attached' and return the attachSerial
        return try await withCheckedThrowingContinuation { continuation in
            // Handle successful attachment
            channelWithProperties.channel?.on(.attached) { _ in
                if let attachSerial = channelWithProperties.properties.attachSerial {
                    continuation.resume(returning: attachSerial)
                } else {
                    continuation.resume(throwing: ARTErrorInfo.create(withCode: 40000, status: 400, message: "Channel is attached, but attachSerial is not defined"))
                }
            }

            // Handle failure
            channelWithProperties.channel?.on(.failed) { _ in
                continuation.resume(throwing: ARTErrorInfo.createUnknownError())
            }
        }
    }


}
