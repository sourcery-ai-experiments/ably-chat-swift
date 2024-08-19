@testable import AblyChat

/// A mock implementation of ``SimpleClock`` which records its arguments but does not actually sleep.
actor MockSimpleClock: SimpleClock {
    private(set) var sleepCallArguments: [UInt64] = []

    func sleep(nanoseconds duration: UInt64) async throws {
        sleepCallArguments.append(duration)
    }
}
