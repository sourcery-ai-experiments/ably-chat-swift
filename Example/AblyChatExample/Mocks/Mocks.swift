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
    
    func get(roomID: String, options: RoomOptions) async throws -> any Room {
        MockRoom(roomID: roomID, options: options)
    }
    
    func release(roomID: String) async throws {
        fatalError("Not yet implemented")
    }
    
    init(clientOptions: ClientOptions) {
        self.clientOptions = clientOptions
    }
}

actor MockRoom: Room {
    internal nonisolated let roomID: String
    internal nonisolated let options: RoomOptions
    
    internal init(roomID: String, options: RoomOptions) {
        self.roomID = roomID
        self.options = options
    }
    
    nonisolated var messages: any Messages {
        MockMessages(clientID: "AblyTest", roomID: roomID)
    }

    nonisolated var presence: any Presence {
        fatalError("Not yet implemented")
    }

    nonisolated var reactions: any RoomReactions {
        fatalError("Not yet implemented")
    }

    nonisolated var typing: any Typing {
        fatalError("Not yet implemented")
    }

    nonisolated var occupancy: any Occupancy {
        fatalError("Not yet implemented")
    }

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
    
    init(clientID: String, roomID: String) {
        self.clientID = clientID
        self.roomID = roomID
        self.channel = MockRealtimeChannel()
    }
    
    func subscribe(bufferingPolicy: BufferingPolicy) async -> MessageSubscription {
        MessageSubscription(mockAsyncSequence: MockMessageSubscription(clientID: clientID, roomID: roomID)) {_ in 
            MockMessagesPaginatedResult(clientID: self.clientID, roomID: self.roomID)
        }
    }
    
    func get(options: QueryOptions) async throws -> any PaginatedResult<Message> {
        MockMessagesPaginatedResult(clientID: self.clientID, roomID: self.roomID)
    }
    
    func send(params: SendMessageParams) async throws -> Message {
        Message(timeserial: "\(Date().timeIntervalSince1970)",
                clientID: self.clientID,
                roomID: self.roomID,
                text: params.text,
                createdAt: Date(),
                metadata: [:],
                headers: [:])
    }
    
    func subscribeToDiscontinuities() -> Subscription<ARTErrorInfo> {
        fatalError("Not yet implemented")
    }
}

struct MockMessageSubscription: Sendable, AsyncSequence, AsyncIteratorProtocol {
    typealias Element = Message
    
    let clientID: String
    let roomID: String
    
    public init(clientID: String, roomID: String) {
        self.clientID = clientID
        self.roomID = roomID
    }
    
    public mutating func next() async -> Element? {
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        return Message(timeserial: "\(Date().timeIntervalSince1970)",
                       clientID: self.clientID,
                       roomID: self.roomID,
                       text: String.randomPhrase(),
                       createdAt: Date(),
                       metadata: [:],
                       headers: [:])
    }
    
    public func makeAsyncIterator() -> Self {
        self
    }
}
