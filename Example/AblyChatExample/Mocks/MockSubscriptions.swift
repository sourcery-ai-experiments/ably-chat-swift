import Ably
import AblyChat

struct MockMessageSubscription: Sendable, AsyncSequence {
    typealias Element = Message
    typealias AsyncIterator = AsyncStream<Element>.Iterator
    
    let clientID: String
    let roomID: String
    
    private let stream: AsyncStream<Element>
    private let continuation: AsyncStream<Element>.Continuation
    
    func emit(message params: SendMessageParams) -> Message {
        let message = Message(timeserial: "\(Date().timeIntervalSince1970)",
                              clientID: clientID,
                              roomID: roomID,
                              text: params.text,
                              createdAt: Date(),
                              metadata: params.metadata ?? [:],
                              headers: params.headers ?? [:])
        continuation.yield(message)
        return message
    }
    
    func emitMessages() {
        Task {
            while (true) {
                try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                _ = emit(message: SendMessageParams(text: String.randomPhrase()))
            }
        }
    }
    
    func makeAsyncIterator() -> AsyncIterator {
        stream.makeAsyncIterator()
    }
    
    init(clientID: String, roomID: String) {
        self.clientID = clientID
        self.roomID = roomID
        let (stream, continuation) = AsyncStream.makeStream(of: Element.self, bufferingPolicy: .unbounded)
        self.stream = stream
        self.continuation = continuation
        emitMessages()
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
