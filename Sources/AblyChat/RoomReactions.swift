import Ably

public protocol RoomReactions: AnyObject, Sendable, EmitsDiscontinuities {
    func send(params: RoomReactionParams) async throws
    func subscribe(bufferingPolicy: BufferingPolicy) async -> Subscription<Reaction>
    var channel: RealtimeChannel { get }
}

public struct RoomReactionParams: Sendable {
    public var type: String
    public var metadata: ReactionMetadata?
    public var headers: ReactionHeaders?

    public init(type: String, metadata: ReactionMetadata? = nil, headers: ReactionHeaders? = nil) {
        self.type = type
        self.metadata = metadata
        self.headers = headers
    }
}
