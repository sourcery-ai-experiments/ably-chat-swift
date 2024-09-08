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
    internal nonisolated let roomID: String
    internal nonisolated let options: RoomOptions
    
    internal init(roomID: String, options: RoomOptions) {
        self.roomID = roomID
        self.options = options
    }
    
    lazy nonisolated var messages: any Messages = MockMessages(clientID: "AblyTest", roomID: roomID)

    lazy nonisolated var presence: any Presence = MockPresence(clientID: "AblyTest", roomID: roomID)

    lazy nonisolated var reactions: any RoomReactions = MockRoomReactions(clientID: "AblyTest", roomID: roomID)

    lazy nonisolated var typing: any Typing = MockTyping(clientID: "AblyTest", roomID: roomID)

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
    
    private var mockSubscription: MockMessageSubscription
    
    init(clientID: String, roomID: String) {
        self.clientID = clientID
        self.roomID = roomID
        self.channel = MockRealtimeChannel()
        self.mockSubscription = MockMessageSubscription(clientID: clientID, roomID: roomID)
    }
    
    func subscribe(bufferingPolicy: BufferingPolicy) async -> MessageSubscription {
        MessageSubscription(mockAsyncSequence: mockSubscription) {_ in
            MockMessagesPaginatedResult(clientID: self.clientID, roomID: self.roomID)
        }
    }
    
    func get(options: QueryOptions) async throws -> any PaginatedResult<Message> {
        MockMessagesPaginatedResult(clientID: self.clientID, roomID: self.roomID)
    }
    
    func send(params: SendMessageParams) async throws -> Message {
        mockSubscription.emit(message: params)
    }
    
    func subscribeToDiscontinuities() -> Subscription<ARTErrorInfo> {
        fatalError("Not yet implemented")
    }
}

actor MockRoomReactions: RoomReactions {
    let clientID: String
    let roomID: String
    let channel: RealtimeChannel
    
    init(clientID: String, roomID: String) {
        self.clientID = clientID
        self.roomID = roomID
        self.channel = MockRealtimeChannel()
    }
    
    func send(params: RoomReactionParams) async throws {
        _ = Reaction(type: "like",
                     metadata: [:],
                     headers: [:],
                     createdAt: Date(),
                     clientID: clientID,
                     isSelf: true)
    }
    
    func subscribe(bufferingPolicy: BufferingPolicy) -> Subscription<Reaction> {
        .init(mockAsyncSequence: MockReactionSubscription(clientID: clientID, roomID: roomID))
    }
    
    func subscribeToDiscontinuities() async -> Subscription<ARTErrorInfo> {
        fatalError("Not yet implemented")
    }
}

actor MockTyping: Typing {
    let clientID: String
    let roomID: String
    let channel: RealtimeChannel
    
    init(clientID: String, roomID: String) {
        self.clientID = clientID
        self.roomID = roomID
        self.channel = MockRealtimeChannel()
    }
    
    func subscribe(bufferingPolicy: BufferingPolicy) -> Subscription<TypingEvent> {
        .init(mockAsyncSequence: MockTypingSubscription(clientID: clientID, roomID: roomID))
    }
    
    func get() async throws -> Set<String> {
        ["User1", "User2"]
    }
    
    func start() async throws {
        fatalError("Not yet implemented")
    }
    
    func stop() async throws {
        fatalError("Not yet implemented")
    }
    
    func subscribeToDiscontinuities() async -> Subscription<ARTErrorInfo> {
        fatalError("Not yet implemented")
    }
}

actor MockPresence: Presence {
    let clientID: String
    let roomID: String
    
    private let members = [ "Alice", "Bob", "Charlie", "Dave", "Eve" ]
    
    init(clientID: String, roomID: String) {
        self.clientID = clientID
        self.roomID = roomID
    }
    
    func get() async throws -> any PaginatedResult<PresenceMember> {
        MockPresencePaginatedResult(members: members)
    }
    
    func get(params: ARTRealtimePresenceQuery?) async throws -> any PaginatedResult<PresenceMember> {
        MockPresencePaginatedResult(members: members)
    }
    
    func isUserPresent(clientID: String) async throws -> Bool {
        fatalError("Not yet implemented")
    }
    
    func enter() async throws {
        fatalError("Not yet implemented")
    }
    
    func enter(data: PresenceData) async throws {
        fatalError("Not yet implemented")
    }
    
    func update() async throws {
        fatalError("Not yet implemented")
    }
    
    func update(data: PresenceData) async throws {
        fatalError("Not yet implemented")
    }
    
    func leave() async throws {
        fatalError("Not yet implemented")
    }
    
    func leave(data: PresenceData) async throws {
        fatalError("Not yet implemented")
    }
    
    func subscribe(event: PresenceEventType) -> Subscription<PresenceEvent> {
        .init(mockAsyncSequence: MockPresenceSubscription(members: members))
    }
    
    func subscribe(events: [PresenceEventType]) -> Subscription<PresenceEvent> {
        .init(mockAsyncSequence: MockPresenceSubscription(members: members))
    }
    
    func subscribeToDiscontinuities() async -> Subscription<ARTErrorInfo> {
        fatalError("Not yet implemented")
    }
}
