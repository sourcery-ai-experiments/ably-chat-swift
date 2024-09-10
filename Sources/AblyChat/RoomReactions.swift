import Ably

public protocol RoomReactions: AnyObject, Sendable, EmitsDiscontinuities {
    func send(params: SendReactionParams) async throws
    func subscribe(bufferingPolicy: BufferingPolicy) -> Subscription<Reaction>
    var channel: ARTRealtimeChannelProtocol { get }
}

public struct SendReactionParams: Sendable {
    public var type: String
    public var metadata: ReactionMetadata?
    public var headers: ReactionHeaders?

    public init(type: String, metadata: ReactionMetadata? = nil, headers: ReactionHeaders? = nil) {
        self.type = type
        self.metadata = metadata
        self.headers = headers
    }
}
