import Ably
import AblyChat

final class MockChatClient: ChatClient {
    
    static let shared = MockChatClient(
        realtime: MockRealtime(key: ""),
        clientOptions: ClientOptions()
    )
    
    public init(realtime _: ARTRealtimeProtocol, clientOptions _: ClientOptions?) {
        // This one doesn’t do `fatalError`, so that I can call it in the example app
    }

    public var rooms: any Rooms {
        MockRooms()
    }

    public var connection: any Connection {
        fatalError("Not yet implemented")
    }

    public var clientID: String {
        fatalError("Not yet implemented")
    }

    public var realtime: any ARTRealtimeProtocol {
        fatalError("Not yet implemented")
    }

    public var clientOptions: ClientOptions {
        fatalError("Not yet implemented")
    }
}

final class MockRooms: Rooms {
    
    func get(roomID: String, options: RoomOptions) -> any Room {
        MockRoom(roomID: "Demo Room")
    }
    
    func release(roomID: String) async throws {
        fatalError("Not yet implemented")
    }
    
    var clientOptions: ClientOptions {
        fatalError("Not yet implemented")
    }
}

final class MockRoom: Room {
    
    let roomID: String
    
    init(roomID: String) {
        self.roomID = roomID
    }
    
    var messages: any Messages {
        MockMessages(clientID: "Demo", roomID: roomID)
    }

    var presence: any Presence {
        fatalError("Not yet implemented")
    }

    var reactions: any RoomReactions {
        fatalError("Not yet implemented")
    }

    var typing: any Typing {
        fatalError("Not yet implemented")
    }

    var occupancy: any Occupancy {
        fatalError("Not yet implemented")
    }
    
    var status: any RoomStatus {
        fatalError("Not yet implemented")
    }
    
    func attach() async throws {
        fatalError("Not yet implemented")
    }
    
    func detach() async throws {
        fatalError("Not yet implemented")
    }
    
    var options: RoomOptions {
        fatalError("Not yet implemented")
    }
}

final class MockMessages: @unchecked Sendable, Messages, ObservableObject {
    let clientID: String
    let roomID: String
    
    @Published var log = [Message]()
    
    func subscribeToDiscontinuities() -> Subscription<ARTErrorInfo> {
        fatalError("Not yet implemented")
    }
    
    init(clientID: String, roomID: String) {
        self.clientID = clientID
        self.roomID = roomID
    }
    
    func subscribe(bufferingPolicy: BufferingPolicy) -> MessageSubscription {
        MessageSubscription(MockMessageSubscription(clientID: clientID, roomID: roomID))
    }
    
    func get(options: QueryOptions) async throws -> any PaginatedResult<Message> {
        fatalError("Not yet implemented")
    }
    
    func send(params: SendMessageParams) async throws -> Message {
        let message = Message(id: UUID(),
                              timeserial: "\(Date().timeIntervalSince1970)",
                              clientID: "Me",
                              roomID: self.roomID,
                              text: params.text,
                              createdAt: Date(),
                              metadata: [:],
                              headers: [:])
        DispatchQueue.main.sync {
            log.append(message)
        }
        return message
    }
    
    var channel: ARTRealtimeChannelProtocol {
        fatalError("Not yet implemented")
    }
}

struct MockMessageSubscription: Sendable, AsyncSequence, AsyncIteratorProtocol {
    public typealias Element = Message

    let clientID: String
    let roomID: String
    
    public init(clientID: String, roomID: String) {
        self.clientID = clientID
        self.roomID = roomID
    }
    
    public func getPreviousMessages(params _: QueryOptionsWithoutDirection) async throws -> any PaginatedResult<Message> {
        fatalError("Not yet implemented")
    }
    
    public mutating func next() async -> Element? {
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        return Message(id: UUID(),
                       timeserial: "\(Date().timeIntervalSince1970)",
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

extension String {
    
    static func randomWord(length: Int = Int.random(in: 1...10)) -> String {
        var word = ""
        for _ in 0..<length {
            let char = String(format: "%c", Int.random(in: 97..<123))
            word += char
        }
        return word
    }
    
    static func randomPhrase(length: Int = Int.random(in: 1...10)) -> String {
        var phrase = ""
        for _ in 0..<length {
            phrase += randomWord() + " "
        }
        phrase += Int.random(in: 1...100) % 5 == 0 ? "😆" : ""
        return phrase.count % 33 == 0 ? "Bingo! 😂" : phrase
    }
}
