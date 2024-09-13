import Ably

public protocol ChatClient: AnyObject, Sendable {
    var rooms: any Rooms { get }
    var connection: any Connection { get }
    var clientID: String { get }
    var realtime: RealtimeClient { get }
    var clientOptions: ClientOptions { get }
}

public typealias RealtimeClient = any RealtimeClientProtocol

@MainActor
public class DefaultChatClient: ChatClient {
    public let realtime: RealtimeClient
    public let rest: ARTRest
    public nonisolated let clientOptions: ClientOptions
    public nonisolated let rooms: Rooms

    public init(realtime: RealtimeClient, rest: ARTRest, clientOptions: ClientOptions?) {
        self.realtime = realtime
        self.clientOptions = clientOptions ?? .init()
        self.rest = rest
        rooms = DefaultRooms(realtime: self.realtime, rest: self.rest, clientOptions: self.clientOptions)
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
