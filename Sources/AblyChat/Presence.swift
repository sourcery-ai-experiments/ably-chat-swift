import Ably

// TODO: (https://github.com/ably-labs/ably-chat-swift/issues/13): try to improve this type
public typealias PresenceData = any Sendable

public protocol Presence: AnyObject, Sendable, EmitsDiscontinuities {
    func get() async throws -> [PresenceMember]
    func get(params: ARTRealtimePresenceQuery?) async throws -> [PresenceMember]
    func isUserPresent(clientID: String) async throws -> Bool
    func enter() async throws
    func enter(data: PresenceData) async throws
    func update() async throws
    func update(data: PresenceData) async throws
    func leave() async throws
    func leave(data: PresenceData) async throws
    func subscribe(event: PresenceEventType) async -> Subscription<PresenceEvent>
    func subscribe(events: [PresenceEventType]) async -> Subscription<PresenceEvent>
}

public struct PresenceMember: Sendable {
    public enum Action: Sendable {
        case present
        case enter
        case leave
        case update
    }

    public init(clientID: String, data: PresenceData, action: PresenceMember.Action, extras: (any Sendable)?, updatedAt: Date) {
        self.clientID = clientID
        self.data = data
        self.action = action
        self.extras = extras
        self.updatedAt = updatedAt
    }

    public var clientID: String
    public var data: PresenceData?
    public var action: Action
    // TODO: (https://github.com/ably-labs/ably-chat-swift/issues/13): try to improve this type
    public var extras: (any Sendable)?
    public var updatedAt: Date
}

public enum PresenceEventType: Sendable {
    case enter
    case leave
    case update
    case present
}

public struct PresenceEvent: Sendable {
    public var action: PresenceEventType
    public var clientID: String
    public var timestamp: Date
    public var data: PresenceData?

    public init(action: PresenceEventType, clientID: String, timestamp: Date, data: PresenceData?) {
        self.action = action
        self.clientID = clientID
        self.timestamp = timestamp
        self.data = data
    }
}
