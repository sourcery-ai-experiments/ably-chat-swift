import Foundation

/// A property wrapper that uses a mutex to protect its wrapped value from concurrent reads and writes. Similar to Objective-C’s `@atomic`.
///
/// Don’t overestimate the abilities of this property wrapper; it won’t allow you to, for example, increment a counter in a threadsafe manner.
@propertyWrapper
struct SynchronizedAccess<T> {
    var wrappedValue: T {
        get {
            let value: T
            mutex.lock()
            value = _wrappedValue
            mutex.unlock()
            return value
        }

        set {
            mutex.lock()
            _wrappedValue = newValue
            mutex.unlock()
        }
    }

    private var _wrappedValue: T
    private var mutex = NSLock()

    init(wrappedValue: T) {
        _wrappedValue = wrappedValue
    }
}
