import Foundation

public typealias MessageHeaders = Headers
public typealias MessageMetadata = Metadata

public struct Message: Sendable, Identifiable {
    public var id: UUID
    public var timeserial: String
    public var clientID: String
    public var roomID: String
    public var text: String
    public var createdAt: Date
    public var metadata: MessageMetadata
    public var headers: MessageHeaders

    public init(id: UUID, timeserial: String, clientID: String, roomID: String, text: String, createdAt: Date, metadata: MessageMetadata, headers: MessageHeaders) {
        self.id = id
        self.timeserial = timeserial
        self.clientID = clientID
        self.roomID = roomID
        self.text = text
        self.createdAt = createdAt
        self.metadata = metadata
        self.headers = headers
    }

    public func isBefore(_: Message) -> Bool {
        fatalError("Not yet implemented")
    }

    public func isAfter(_: Message) -> Bool {
        fatalError("Not yet implemented")
    }

    public func isEqual(_: Message) -> Bool {
        fatalError("Not yet implemented")
    }
}
