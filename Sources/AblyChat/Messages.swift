import Ably

public protocol Messages: AnyObject, Sendable, EmitsDiscontinuities {
    var log: [Message] { get }
    func subscribe(bufferingPolicy: BufferingPolicy) -> MessageSubscription
    func get(options: QueryOptions) async throws -> any PaginatedResult<Message>
    func send(params: SendMessageParams) async throws -> Message
    var channel: ARTRealtimeChannelProtocol { get }
}

public struct SendMessageParams: Sendable {
    public var text: String
    public var metadata: MessageMetadata?
    public var headers: MessageHeaders?

    public init(text: String, metadata: MessageMetadata? = nil, headers: MessageHeaders? = nil) {
        self.text = text
        self.metadata = metadata
        self.headers = headers
    }
}

public struct QueryOptions: Sendable {
    public enum Direction: Sendable {
        case forwards
        case backwards
    }

    public var start: Date?
    public var end: Date?
    public var limit: Int?
    public var direction: Direction?

    public init(start: Date? = nil, end: Date? = nil, limit: Int? = nil, direction: QueryOptions.Direction? = nil) {
        self.start = start
        self.end = end
        self.limit = limit
        self.direction = direction
    }
}

public struct QueryOptionsWithoutDirection: Sendable {
    public var start: Date?
    public var end: Date?
    public var limit: Int?

    public init(start: Date? = nil, end: Date? = nil, limit: Int? = nil) {
        self.start = start
        self.end = end
        self.limit = limit
    }
}

// Currently a copy-and-paste of `Subscription`; see notes on that one. For `MessageSubscription`, my intention is that the `BufferingPolicy` passed to `subscribe(bufferingPolicy:)` will also define what the `MessageSubscription` does with messages that are received _before_ the user starts iterating over the sequence (this buffering will allow us to implement the requirement that there be no discontinuity between the the last message returned by `getPreviousMessages` and the first element you get when you iterate).
public struct MessageSubscription: Sendable, AsyncSequence, AsyncIteratorProtocol {
    public typealias Element = Message

    var mockAsyncSequence: any AsyncSequence & AsyncIteratorProtocol & Sendable
    
    public init<T: AsyncSequence>(_ mock: T) where T.Element == Element {
        self.mockAsyncSequence = mock as! any Sendable & AsyncIteratorProtocol & AsyncSequence
    }

    public func getPreviousMessages(params _: QueryOptionsWithoutDirection) async throws -> any PaginatedResult<Message> {
        fatalError("Not yet implemented")
    }
    
    public mutating func next() async -> Element? {
        try! await mockAsyncSequence.next() as! MessageSubscription.Element
    }
    
    public func makeAsyncIterator() -> Self {
        self
    }
}
