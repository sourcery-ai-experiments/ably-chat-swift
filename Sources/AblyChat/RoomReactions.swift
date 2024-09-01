import Ably

public protocol RoomReactions: AnyObject, Sendable, EmitsDiscontinuities {
    func send(params: RoomReactionParams) async throws
    func subscribe(bufferingPolicy: BufferingPolicy) async -> Subscription<Reaction>
    var channel: RealtimeChannel { get }
}

public struct RoomReactionParams: Sendable {
    public init() {}
}
