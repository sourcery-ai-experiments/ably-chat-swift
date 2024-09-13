import Ably
import AblyChat

struct MockSubscription<T: Sendable>: Sendable, AsyncSequence {
    typealias Element = T
    typealias AsyncIterator = AsyncStream<T>.Iterator
    
    private let stream: AsyncStream<T>
    private let continuation: AsyncStream<T>.Continuation
    
    func emit(_ object: T) {
        continuation.yield(object)
    }
    
    func startEmitting(randomElement: @escaping @Sendable () -> T, interval: UInt64) {
        Task {
            while (true) {
                try? await Task.sleep(nanoseconds: interval * 1_000_000_000)
                emit(randomElement())
            }
        }
    }
    
    func makeAsyncIterator() -> AsyncIterator {
        stream.makeAsyncIterator()
    }
    
    init(randomElement: @escaping @Sendable () -> T, interval: UInt64) {
        let (stream, continuation) = AsyncStream.makeStream(of: Element.self, bufferingPolicy: .unbounded)
        self.stream = stream
        self.continuation = continuation
        startEmitting(randomElement: randomElement, interval: interval)
    }
}
