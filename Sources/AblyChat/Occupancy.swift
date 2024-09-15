import Ably

public protocol Occupancy: AnyObject, Sendable, EmitsDiscontinuities {
    func subscribe(bufferingPolicy: BufferingPolicy) async -> Subscription<OccupancyEvent>
    func get() async throws -> OccupancyEvent
    var channel: RealtimeChannel { get }
}

public struct OccupancyEvent: Sendable {
    public var connections: Int
    public var presenceMembers: Int

    public init(connections: Int, presenceMembers: Int) {
        self.connections = connections
        self.presenceMembers = presenceMembers
    }
}
