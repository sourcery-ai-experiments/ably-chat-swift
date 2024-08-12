// A non-throwing `AsyncSequence` (means that we can iterate over it without a `try`).
//
// This should respect the `BufferingPolicy` passed to the `subscribe(bufferingPolicy:)` method.
//
// At some point we should define how this thing behaves when you iterate over it from multiple loops, or when you pass it around. I’m not yet sufficiently experienced with `AsyncSequence` to know what’s idiomatic. I tried the same thing out with `AsyncStream` (two tasks iterating over a single stream) and it appears that each element is delivered to precisely one consumer. But we can leave that for later. On a similar note consider whether it makes a difference whether this is a struct or a class.
//
// TODO: I wanted to implement this as a protocol (from which `MessageSubscription` would then inherit) but struggled to do so, hence the struct. Try again sometime. We can also revisit our implementation of `AsyncSequence` if we migrate to Swift 6, which adds primary types and typed errors to `AsyncSequence` and should make things easier.
public struct Subscription<Element>: Sendable, AsyncSequence {
    // This is a workaround for the fact that, as mentioned above, `Subscription` is a struct when I would have liked it to be a protocol. It allows people mocking our SDK to create a `Subscription` so that they can return it from their mocks. The intention of this initializer is that if you use it, then the created `Subscription` will just replay the sequence that you pass it.
    public init<T: AsyncSequence>(mockAsyncSequence _: T) where T.Element == Element {
        fatalError("Not implemented")
    }

    // (The below is just necessary boilerplate to get this to compile; the key point is that `next()` does not have a `throws` annotation.)

    public struct AsyncIterator: AsyncIteratorProtocol {
        public mutating func next() async -> Element? {
            fatalError("Not implemented")
        }
    }

    public func makeAsyncIterator() -> AsyncIterator {
        fatalError("Not implemented")
    }
}
