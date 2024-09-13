@testable import AblyChat
import XCTest

class DefaultRoomStatusTests: XCTestCase {
    func test_current_startsAsInitialized() async {
        let status = DefaultRoomStatus(logger: TestLogger())
        let current = await status.current
        XCTAssertEqual(current, .initialized)
    }

    func test_error_startsAsNil() async {
        let status = DefaultRoomStatus(logger: TestLogger())
        let error = await status.error
        XCTAssertNil(error)
    }

    func test_transition() async {
        // Given: A RoomStatus
        let status = DefaultRoomStatus(logger: TestLogger())
        let originalState = await status.current
        let newState = RoomLifecycle.attached // arbitrary

        let subscription1 = await status.onChange(bufferingPolicy: .unbounded)
        let subscription2 = await status.onChange(bufferingPolicy: .unbounded)

        async let statusChange1 = subscription1.first { $0.current == newState }
        async let statusChange2 = subscription2.first { $0.current == newState }

        // When: transition(to:) is called
        await status.transition(to: newState)

        // Then: It emits a status change to all subscribers added via onChange(bufferingPolicy:), and updates its `current` property to the new state
        guard let statusChange1 = await statusChange1, let statusChange2 = await statusChange2 else {
            XCTFail("Expected status changes to be emitted")
            return
        }

        for statusChange in [statusChange1, statusChange2] {
            XCTAssertEqual(statusChange.previous, originalState)
            XCTAssertEqual(statusChange.current, newState)
        }

        let current = await status.current
        XCTAssertEqual(current, .attached)
    }
}
