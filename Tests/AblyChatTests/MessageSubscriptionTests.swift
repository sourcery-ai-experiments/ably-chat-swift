@testable import AblyChat
import AsyncAlgorithms
import XCTest

private final class MockPaginatedResult<T>: PaginatedResult {
    var items: [T] { fatalError("Not implemented") }

    var hasNext: Bool { fatalError("Not implemented") }

    var isLast: Bool { fatalError("Not implemented") }

    var next: (any AblyChat.PaginatedResult<T>)? { fatalError("Not implemented") }

    var first: any AblyChat.PaginatedResult<T> { fatalError("Not implemented") }

    var current: any AblyChat.PaginatedResult<T> { fatalError("Not implemented") }

    init() {}
}

class MessageSubscriptionTests: XCTestCase {
    let messages = ["First", "Second"].map { text in
        Message(timeserial: "", clientID: "", roomID: "", text: text, createdAt: .init(), metadata: [:], headers: [:])
    }

    func testWithMockAsyncSequence() async {
        let subscription = MessageSubscription(mockAsyncSequence: messages.async) { _ in fatalError("Not implemented") }

        async let emittedElements = Array(subscription.prefix(2))

        let awaitedEmittedElements = await emittedElements
        XCTAssertEqual(awaitedEmittedElements.map(\.text), ["First", "Second"])
    }

    func testEmit() async {
        let subscription = MessageSubscription(bufferingPolicy: .unbounded)

        async let emittedElements = Array(subscription.prefix(2))

        subscription.emit(messages[0])
        subscription.emit(messages[1])

        let awaitedEmittedElements = await emittedElements
        XCTAssertEqual(awaitedEmittedElements.map(\.text), ["First", "Second"])
    }

    func testMockGetPreviousMessages() async throws {
        let mockPaginatedResult = MockPaginatedResult<Message>()
        let subscription = MessageSubscription(mockAsyncSequence: [].async) { _ in mockPaginatedResult }

        let result = try await subscription.getPreviousMessages(params: .init())
        // This dance is to avoid the compiler error "Runtime support for parameterized protocol types is only available in iOS 16.0.0 or newer" — casting back to a concrete type seems to avoid this
        let resultAsConcreteType = try XCTUnwrap(result as? MockPaginatedResult<Message>)
        XCTAssertIdentical(resultAsConcreteType, mockPaginatedResult)
    }
}
