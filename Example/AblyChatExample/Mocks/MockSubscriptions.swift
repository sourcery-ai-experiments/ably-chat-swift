import Ably
import AblyChat
import AsyncAlgorithms

struct MockSubscription<T: Sendable>: Sendable, AsyncSequence {
    typealias Element = T
    typealias AsyncTimerMockSequence = AsyncMapSequence<AsyncTimerSequence<ContinuousClock>, Element>
    typealias MockMergedSequence = AsyncMerge2Sequence<AsyncStream<Element>, AsyncTimerMockSequence>
    typealias AsyncIterator = MockMergedSequence.Iterator
    
    private let continuation: AsyncStream<Element>.Continuation
    private let mergedSequence: MockMergedSequence
    
    func emit(_ object: Element) {
        continuation.yield(object)
    }
    
    func makeAsyncIterator() -> AsyncIterator {
        mergedSequence.makeAsyncIterator()
    }
    
    init(randomElement: @escaping @Sendable () -> Element, interval: Double) {
        let (stream, continuation) = AsyncStream.makeStream(of: Element.self, bufferingPolicy: .unbounded)
        self.continuation = continuation
        let timer: AsyncTimerSequence<ContinuousClock> = .init(interval: .seconds(interval), clock: .init())
        self.mergedSequence = merge(stream, timer.map { _ in
            randomElement()
        })
    }
}
