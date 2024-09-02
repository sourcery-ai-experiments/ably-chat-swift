@testable import AblyChat
import XCTest

class DefaultChatClientTests: XCTestCase {
    func test_init_withoutClientOptions() {
        // Given: An instance of DefaultChatClient is created with nil clientOptions
        let client = DefaultChatClient(realtime: MockRealtime.create(), clientOptions: nil)

        // Then: It uses the default client options
        let defaultOptions = ClientOptions()
        XCTAssertTrue(client.clientOptions.isEqualForTestPurposes(defaultOptions))
    }

    func test_rooms() throws {
        // Given: An instance of DefaultChatClient
        let realtime = MockRealtime.create()
        let options = ClientOptions()
        let client = DefaultChatClient(realtime: realtime, clientOptions: options)

        // Then: Its `rooms` property returns an instance of DefaultRooms with the same realtime client and client options
        let rooms = client.rooms

        let defaultRooms = try XCTUnwrap(rooms as? DefaultRooms)
        XCTAssertIdentical(defaultRooms.realtime, realtime)
        XCTAssertTrue(defaultRooms.clientOptions.isEqualForTestPurposes(options))
    }
}
