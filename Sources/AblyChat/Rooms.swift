import Ably

public protocol Rooms: AnyObject, Sendable {
    func get(roomID: String, options: RoomOptions) throws -> any Room
    func release(roomID: String) async throws
    var clientOptions: ClientOptions { get }
}

internal actor DefaultRooms: Rooms {
    /// Exposed so that we can test it.
    internal nonisolated let realtime: RealtimeClient
    internal nonisolated let clientOptions: ClientOptions

    internal init(realtime: RealtimeClient, clientOptions: ClientOptions) {
        self.realtime = realtime
        self.clientOptions = clientOptions
    }

    internal nonisolated func get(roomID _: String, options _: RoomOptions) throws -> any Room {
        fatalError("Not yet implemented")
    }

    internal func release(roomID _: String) async throws {
        fatalError("Not yet implemented")
    }
}
