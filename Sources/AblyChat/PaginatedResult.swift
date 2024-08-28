public protocol PaginatedResult<T>: AnyObject, Sendable {
    associatedtype T

    var items: [T] { get }
    var hasNext: Bool { get }
    var isLast: Bool { get }
    // TODO: (https://github.com/ably-labs/ably-chat-swift/issues/11): consider how to avoid the need for an unwrap
    var next: (any PaginatedResult<T>)? { get async throws }
    var first: any PaginatedResult<T> { get async throws }
    var current: any PaginatedResult<T> { get async throws }
}
