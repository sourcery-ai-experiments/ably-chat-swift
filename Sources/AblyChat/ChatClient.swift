import Ably

public protocol ChatClient: AnyObject, Sendable {
    var rooms: any Rooms { get }
    var connection: any Connection { get }
    var clientID: String { get }
    var realtime: RealtimeClient { get }
    var clientOptions: ClientOptions { get }
}

public typealias RealtimeClient = any(ARTRealtimeProtocol & Sendable)

public actor DefaultChatClient: ChatClient {
    public let realtime: RealtimeClient
    public nonisolated let clientOptions: ClientOptions
    public nonisolated let rooms: Rooms

    public init(realtime: RealtimeClient, clientOptions: ClientOptions?) {
        self.realtime = realtime
        self.clientOptions = clientOptions ?? .init()
        rooms = DefaultRooms(realtime: realtime, clientOptions: self.clientOptions)
    }

    public nonisolated var connection: any Connection {
        fatalError("Not yet implemented")
    }

    public nonisolated var clientID: String {
        fatalError("Not yet implemented")
    }
}

public struct ClientOptions: Sendable {
    public var logHandler: LogHandler?
    public var logLevel: LogLevel?

    public init(logHandler: (any LogHandler)? = nil, logLevel: LogLevel? = nil) {
        self.logHandler = logHandler
        self.logLevel = logLevel
    }

    /// Used for comparing these instances in tests without having to make this Equatable, which I’m not yet sure makes sense (we’ll decide in https://github.com/ably-labs/ably-chat-swift/issues/10)
    internal func isEqualForTestPurposes(_ other: ClientOptions) -> Bool {
        logHandler === other.logHandler && logLevel == other.logLevel
    }
}
