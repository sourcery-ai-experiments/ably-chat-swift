import Ably

public protocol RoomStatus: AnyObject, Sendable {
    var current: RoomLifecycle { get }
    // TODO: (https://github.com/ably-labs/ably-chat-swift/issues/12): consider how to avoid the need for an unwrap
    var error: ARTErrorInfo? { get }
    func onChange(bufferingPolicy: BufferingPolicy) -> Subscription<RoomStatusChange>
}

public enum RoomLifecycle: Sendable {
    case initialized
    case attaching
    case attached
    case detaching
    case detached
    case suspended
    case failed
    case releasing
    case released
}

public struct RoomStatusChange: Sendable {
    public var current: RoomLifecycle
    public var previous: RoomLifecycle
    // TODO: (https://github.com/ably-labs/ably-chat-swift/issues/12): consider how to avoid the need for an unwrap
    public var error: ARTErrorInfo?

    public init(current: RoomLifecycle, previous: RoomLifecycle, error: ARTErrorInfo? = nil) {
        self.current = current
        self.previous = previous
        self.error = error
    }
}
