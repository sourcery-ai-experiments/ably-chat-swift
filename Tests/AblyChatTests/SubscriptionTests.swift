@testable import AblyChat
import AsyncAlgorithms
import XCTest

class SubscriptionTests: XCTestCase {
    func testWithMockAsyncSequence() async {
        let subscription = Subscription(mockAsyncSequence: ["First", "Second"].async)

        async let emittedElements = Array(subscription.prefix(2))

        let awaitedEmittedElements = await emittedElements
        XCTAssertEqual(awaitedEmittedElements, ["First", "Second"])
    }

    func testEmit() async {
        let subscription = Subscription<String>(bufferingPolicy: .unbounded)

        async let emittedElements = Array(subscription.prefix(2))

        subscription.emit("First")
        subscription.emit("Second")

        let awaitedEmittedElements = await emittedElements
        XCTAssertEqual(awaitedEmittedElements, ["First", "Second"])
    }
}
