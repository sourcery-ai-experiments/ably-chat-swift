import Ably
import AblyChat

actor MockChatClient: ChatClient {
    let realtime: RealtimeClient
    nonisolated let clientOptions: ClientOptions
    nonisolated let rooms: Rooms

    init(realtime: RealtimeClient, clientOptions: ClientOptions?) {
        self.realtime = realtime
        self.clientOptions = clientOptions ?? .init()
        self.rooms = MockRooms(clientOptions: self.clientOptions)
    }
    
    nonisolated var connection: any Connection {
        fatalError("Not yet implemented")
    }

    nonisolated var clientID: String {
        fatalError("Not yet implemented")
    }
}

actor MockRooms: Rooms {
    let clientOptions: ClientOptions
    private var rooms = [String: MockRoom]()
    
    func get(roomID: String, options: RoomOptions) async throws -> any Room {
        if let room = rooms[roomID] {
            return room
        }
        let room = MockRoom(roomID: roomID, options: options)
        rooms[roomID] = room
        return room
    }
    
    func release(roomID: String) async throws {
        fatalError("Not yet implemented")
    }
    
    init(clientOptions: ClientOptions) {
        self.clientOptions = clientOptions
    }
}

actor MockRoom: Room {
    private let clientID = "AblyTest"
    
    internal nonisolated let roomID: String
    internal nonisolated let options: RoomOptions
    
    internal init(roomID: String, options: RoomOptions) {
        self.roomID = roomID
        self.options = options
    }
    
    lazy nonisolated var messages: any Messages = MockMessages(clientID: clientID, roomID: roomID)

    lazy nonisolated var presence: any Presence = MockPresence(clientID: clientID, roomID: roomID)

    lazy nonisolated var reactions: any RoomReactions = MockRoomReactions(clientID: clientID, roomID: roomID)

    lazy nonisolated var typing: any Typing = MockTyping(clientID: clientID, roomID: roomID)

    lazy nonisolated var occupancy: any Occupancy = MockOccupancy(clientID: clientID, roomID: roomID)

    nonisolated var status: any RoomStatus {
        fatalError("Not yet implemented")
    }

    func attach() async throws {
        fatalError("Not yet implemented")
    }

    func detach() async throws {
        fatalError("Not yet implemented")
    }
}

actor MockMessages: Messages {
    let clientID: String
    let roomID: String
    let channel: RealtimeChannel
    
    private var mockSubscription: MockSubscription<Message>!
    
    init(clientID: String, roomID: String) {
        self.clientID = clientID
        self.roomID = roomID
        self.channel = MockRealtime.Channel()
    }
    
    private func createSubscription() {
        mockSubscription = MockSubscription<Message>(randomElement: {
            Message(timeserial: "\(Date().timeIntervalSince1970)",
                    clientID: MockStrings.names.randomElement()!,
                    roomID: self.roomID,
                    text: MockStrings.randomPhrase(),
                    createdAt: Date(),
                    metadata: [:],
                    headers: [:])
        }, interval: 3)
    }
    
    func subscribe(bufferingPolicy: BufferingPolicy) async -> MessageSubscription {
        createSubscription() // TODO: https://github.com/ably-labs/ably-chat-swift/issues/44
        return MessageSubscription(mockAsyncSequence: mockSubscription) {_ in
            MockMessagesPaginatedResult(clientID: self.clientID, roomID: self.roomID)
        }
    }
    
    func get(options: QueryOptions) async throws -> any PaginatedResult<Message> {
        MockMessagesPaginatedResult(clientID: self.clientID, roomID: self.roomID)
    }
    
    func send(params: SendMessageParams) async throws -> Message {
        guard let mockSubscription = mockSubscription else {
            fatalError("Call `subscribe` first.")
        }
        let message = Message(timeserial: "\(Date().timeIntervalSince1970)",
                              clientID: clientID,
                              roomID: roomID,
                              text: params.text,
                              createdAt: Date(),
                              metadata: params.metadata ?? [:],
                              headers: params.headers ?? [:])
        mockSubscription.emit(message)
        return message
    }
    
    func subscribeToDiscontinuities() -> Subscription<ARTErrorInfo> {
        fatalError("Not yet implemented")
    }
}

actor MockRoomReactions: RoomReactions {
    let clientID: String
    let roomID: String
    let channel: RealtimeChannel
    
    private var mockSubscription: MockSubscription<Reaction>!
    
    init(clientID: String, roomID: String) {
        self.clientID = clientID
        self.roomID = roomID
        self.channel = MockRealtime.Channel()
    }
    
    private func createSubscription() {
        mockSubscription = MockSubscription<Reaction>(randomElement: {
            Reaction(type: ReactionType.allCases.randomElement()!.rawValue,
                     metadata: [:],
                     headers: [:],
                     createdAt: Date(),
                     clientID: self.clientID,
                     isSelf: false)
        }, interval: 1)
    }
    
    func send(params: SendReactionParams) async throws {
        guard let mockSubscription = mockSubscription else {
            fatalError("Call `subscribe` first.")
        }
        let reaction = Reaction(type: params.type,
                               metadata: [:],
                               headers: [:],
                               createdAt: Date(),
                               clientID: clientID,
                               isSelf: false)
        mockSubscription.emit(reaction)
    }
    
    func subscribe(bufferingPolicy: BufferingPolicy) -> Subscription<Reaction> {
        createSubscription()
        return .init(mockAsyncSequence: mockSubscription)
    }
    
    func subscribeToDiscontinuities() async -> Subscription<ARTErrorInfo> {
        fatalError("Not yet implemented")
    }
}

actor MockTyping: Typing {
    let clientID: String
    let roomID: String
    let channel: RealtimeChannel
    
    private var mockSubscription: MockSubscription<TypingEvent>!
    
    init(clientID: String, roomID: String) {
        self.clientID = clientID
        self.roomID = roomID
        self.channel = MockRealtime.Channel()
    }
    
    private func createSubscription() {
        mockSubscription = MockSubscription<TypingEvent>(randomElement: {
            TypingEvent(currentlyTyping: [
                MockStrings.names.randomElement()!,
                MockStrings.names.randomElement()!
            ])
        }, interval: 2)
    }
    
    func subscribe(bufferingPolicy: BufferingPolicy) -> Subscription<TypingEvent> {
        createSubscription()
        return .init(mockAsyncSequence: mockSubscription)
    }
    
    func get() async throws -> Set<String> {
        Set(MockStrings.names.prefix(2))
    }
    
    func start() async throws {
        guard let mockSubscription = mockSubscription else {
            fatalError("Call `subscribe` first.")
        }
        mockSubscription.emit(TypingEvent(currentlyTyping: [clientID]))
    }
    
    func stop() async throws {
        guard let mockSubscription = mockSubscription else {
            fatalError("Call `subscribe` first.")
        }
        mockSubscription.emit(TypingEvent(currentlyTyping: [clientID]))
    }
    
    func subscribeToDiscontinuities() async -> Subscription<ARTErrorInfo> {
        fatalError("Not yet implemented")
    }
}

actor MockPresence: Presence {
    let clientID: String
    let roomID: String
    
    private var mockSubscription: MockSubscription<PresenceEvent>!
    
    init(clientID: String, roomID: String) {
        self.clientID = clientID
        self.roomID = roomID
    }
    
    private func createSubscription() {
        mockSubscription = MockSubscription<PresenceEvent>(randomElement: {
            PresenceEvent(action: [.enter, .leave].randomElement()!,
                          clientID: MockStrings.names.randomElement()!,
                          timestamp: Date(),
                          data: nil)
        }, interval: 5)
    }
    
    func get() async throws -> [PresenceMember] {
        MockStrings.names.map { name in
            PresenceMember(clientID: name,
                           data: ["foo": "bar"],
                           action: .present,
                           extras: nil,
                           updatedAt: Date())
        }
    }
    
    func get(params: ARTRealtimePresenceQuery?) async throws -> [PresenceMember] {
        MockStrings.names.map { name in
            PresenceMember(clientID: name,
                           data: ["foo": "bar"],
                           action: .present,
                           extras: nil,
                           updatedAt: Date())
        }
    }
    
    func isUserPresent(clientID: String) async throws -> Bool {
        fatalError("Not yet implemented")
    }
    
    func enter() async throws {
        guard let mockSubscription = mockSubscription else {
            fatalError("Call `subscribe` first.")
        }
        mockSubscription.emit(PresenceEvent(action: .enter,
                                            clientID: clientID,
                                            timestamp: Date(),
                                            data: nil))
    }
    
    func enter(data: PresenceData) async throws {
        guard let mockSubscription = mockSubscription else {
            fatalError("Call `subscribe` first.")
        }
        mockSubscription.emit(PresenceEvent(action: .enter,
                                            clientID: clientID,
                                            timestamp: Date(),
                                            data: data))
    }
    
    func update() async throws {
        fatalError("Not yet implemented")
    }
    
    func update(data: PresenceData) async throws {
        fatalError("Not yet implemented")
    }
    
    func leave() async throws {
        guard let mockSubscription = mockSubscription else {
            fatalError("Call `subscribe` first.")
        }
        mockSubscription.emit(PresenceEvent(action: .leave,
                                            clientID: clientID,
                                            timestamp: Date(),
                                            data: nil))
    }
    
    func leave(data: PresenceData) async throws {
        guard let mockSubscription = mockSubscription else {
            fatalError("Call `subscribe` first.")
        }
        mockSubscription.emit(PresenceEvent(action: .leave,
                                            clientID: clientID,
                                            timestamp: Date(),
                                            data: data))
    }
    
    func subscribe(event: PresenceEventType) -> Subscription<PresenceEvent> {
        createSubscription()
        return .init(mockAsyncSequence: mockSubscription)
    }
    
    func subscribe(events: [PresenceEventType]) -> Subscription<PresenceEvent> {
        createSubscription()
        return .init(mockAsyncSequence: mockSubscription)
    }
    
    func subscribeToDiscontinuities() async -> Subscription<ARTErrorInfo> {
        fatalError("Not yet implemented")
    }
}

actor MockOccupancy: Occupancy {
    let clientID: String
    let roomID: String
    let channel: RealtimeChannel
    
    private var mockSubscription: MockSubscription<OccupancyEvent>!
    
    init(clientID: String, roomID: String) {
        self.clientID = clientID
        self.roomID = roomID
        self.channel = MockRealtime.Channel()
    }
    
    private func createSubscription() {
        mockSubscription = MockSubscription<OccupancyEvent>(randomElement: {
            let random = Int.random(in: 1...10)
            return OccupancyEvent(connections: random, presenceMembers: Int.random(in: 0...random))
        }, interval: 1)
    }
    
    func subscribe(bufferingPolicy: BufferingPolicy) async -> Subscription<OccupancyEvent> {
        createSubscription()
        return .init(mockAsyncSequence: mockSubscription)
    }
    
    func get() async throws -> OccupancyEvent {
        OccupancyEvent(connections: 10, presenceMembers: 5)
    }
    
    func subscribeToDiscontinuities() async -> Subscription<ARTErrorInfo> {
        fatalError("Not yet implemented")
    }
}
