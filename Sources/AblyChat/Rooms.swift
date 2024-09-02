import Ably

public protocol Rooms: AnyObject, Sendable {
    func get(roomID: String, options: RoomOptions) async throws -> any Room
    func release(roomID: String) async throws
    var clientOptions: ClientOptions { get }
}

internal actor DefaultRooms: Rooms {
    /// Exposed so that we can test it.
    internal nonisolated let realtime: RealtimeClient
    internal nonisolated let clientOptions: ClientOptions

    /// The set of rooms, keyed by room ID.
    private var rooms: [String: DefaultRoom] = [:]

    internal init(realtime: RealtimeClient, clientOptions: ClientOptions) {
        self.realtime = realtime
        self.clientOptions = clientOptions
    }

    internal func get(roomID: String, options: RoomOptions) throws -> any Room {
        // CHA-RC1b
        if let existingRoom = rooms[roomID] {
            if existingRoom.options != options {
                throw ARTErrorInfo(
                    chatError: .inconsistentRoomOptions(requested: options, existing: existingRoom.options)
                )
            }

            return existingRoom
        } else {
            let room = DefaultRoom(realtime: realtime, roomID: roomID, options: options)
            rooms[roomID] = room
            return room
        }
    }

    internal func release(roomID _: String) async throws {
        fatalError("Not yet implemented")
    }
}
