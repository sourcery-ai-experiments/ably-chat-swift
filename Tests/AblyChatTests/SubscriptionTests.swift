@testable import AblyChat
import AsyncAlgorithms
import Testing

struct SubscriptionTests {
    @Test
    func withMockAsyncSequence() async {
        let subscription = Subscription(mockAsyncSequence: ["First", "Second"].async)

        #expect(await Array(subscription.prefix(2)) == ["First", "Second"])
    }

    @Test
    func emit() async {
        let subscription = Subscription<String>(bufferingPolicy: .unbounded)

        async let emittedElements = Array(subscription.prefix(2))

        subscription.emit("First")
        subscription.emit("Second")

        #expect(await emittedElements == ["First", "Second"])
    }
}
