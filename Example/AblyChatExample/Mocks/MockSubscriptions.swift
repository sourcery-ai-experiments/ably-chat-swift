import Ably
import AblyChat

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

struct MockReactionSubscription: Sendable, AsyncSequence, AsyncIteratorProtocol {
    typealias Element = Reaction
    
    let clientID: String
    let roomID: String
    
    public init(clientID: String, roomID: String) {
        self.clientID = clientID
        self.roomID = roomID
    }
    
    public mutating func next() async -> Element? {
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        return Reaction(type: "like",
                        metadata: [:],
                        headers: [:],
                        createdAt: Date(),
                        clientID: self.clientID,
                        isSelf: false)
    }
    
    public func makeAsyncIterator() -> Self {
        self
    }
}

struct MockTypingSubscription: Sendable, AsyncSequence, AsyncIteratorProtocol {
    typealias Element = TypingEvent
    
    let clientID: String
    let roomID: String
    
    public init(clientID: String, roomID: String) {
        self.clientID = clientID
        self.roomID = roomID
    }
    
    public mutating func next() async -> Element? {
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        return TypingEvent(currentlyTyping: ["User1", "User2"])
    }
    
    public func makeAsyncIterator() -> Self {
        self
    }
}

struct MockPresenceSubscription: Sendable, AsyncSequence, AsyncIteratorProtocol {
    typealias Element = PresenceEvent
    
    private let members: [String]
    
    init(members: [String]) {
        self.members = members
    }
    
    public mutating func next() async -> Element? {
        try? await Task.sleep(nanoseconds: 4 * 1_000_000_000)
        return PresenceEvent(action: [.enter, .leave].randomElement()!,
                             clientID: members.randomElement()!,
                             timestamp: Date(),
                             data: nil)
    }
    
    public func makeAsyncIterator() -> Self {
        self
    }
}
