import Ably

// This file contains extensions to ably-cocoa’s types, to make them easier to use in Swift concurrency.
// TODO: remove once we improve this experience in ably-cocoa (https://github.com/ably/ably-cocoa/issues/1967)

internal extension ARTRealtimeChannelProtocol {
    func attachAsync() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, _>) in
            attach { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    func detachAsync() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, _>) in
            detach { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
