@testable import AblyChat
import XCTest

class DefaultRoomsTests: XCTestCase {
    // @spec CHA-RC1a
    func test_get_returnsRoomWithGivenID() async throws {
        // Given: an instance of DefaultRooms
        let realtime = MockRealtime.create()
        let rooms = DefaultRooms(realtime: realtime, clientOptions: .init())

        // When: get(roomID:options:) is called
        let roomID = "basketball"
        let options = RoomOptions()
        let room = try await rooms.get(roomID: roomID, options: options)

        // Then: It returns a DefaultRoom instance that uses the same Realtime instance, with the given ID and options
        let defaultRoom = try XCTUnwrap(room as? DefaultRoom)
        XCTAssertIdentical(defaultRoom.realtime, realtime)
        XCTAssertEqual(defaultRoom.roomID, roomID)
        XCTAssertEqual(defaultRoom.options, options)
    }

    // @spec CHA-RC1b
    func test_get_returnsExistingRoomWithGivenID() async throws {
        // Given: an instance of DefaultRooms, on which get(roomID:options:) has already been called with a given ID
        let realtime = MockRealtime.create()
        let rooms = DefaultRooms(realtime: realtime, clientOptions: .init())

        let roomID = "basketball"
        let options = RoomOptions()
        let firstRoom = try await rooms.get(roomID: roomID, options: options)

        // When: get(roomID:options:) is called with the same room ID
        let secondRoom = try await rooms.get(roomID: roomID, options: options)

        // Then: It returns the same room object
        XCTAssertIdentical(secondRoom, firstRoom)
    }

    // @spec CHA-RC1c
    func test_get_throwsErrorWhenOptionsDoNotMatch() async throws {
        // Given: an instance of DefaultRooms, on which get(roomID:options:) has already been called with a given ID and options
        let realtime = MockRealtime.create()
        let rooms = DefaultRooms(realtime: realtime, clientOptions: .init())

        let roomID = "basketball"
        let options = RoomOptions()
        _ = try await rooms.get(roomID: roomID, options: options)

        // When: get(roomID:options:) is called with the same ID but different options
        let differentOptions = RoomOptions(presence: .init(subscribe: false))

        let caughtError: Error?
        do {
            _ = try await rooms.get(roomID: roomID, options: differentOptions)
            caughtError = nil
        } catch {
            caughtError = error
        }

        // Then: It throws an inconsistentRoomOptions error
        try assertIsChatError(caughtError, withCode: .inconsistentRoomOptions)
    }
}
