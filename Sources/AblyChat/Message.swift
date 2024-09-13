import Foundation

public typealias MessageHeaders = Headers
public typealias MessageMetadata = Metadata

public struct Message: Sendable, Codable, Hashable {
    
    public var timeserial: String
    public var clientID: String?
    public var roomID: String
    public var text: String
    public var createdAt: Date?
    public var metadata: MessageMetadata
    public var headers: MessageHeaders

    public init(timeserial: String, clientID: String?, roomID: String, text: String, createdAt: Date?, metadata: MessageMetadata, headers: MessageHeaders) {
        self.timeserial = timeserial
        self.clientID = clientID
        self.roomID = roomID
        self.text = text
        self.createdAt = createdAt
        self.metadata = metadata
        self.headers = headers
    }
    
    enum CodingKeys: String, CodingKey {
        case timeserial = "timeserial"
        case clientID = "clientId"
        case roomID = "roomId"
        case text = "text"
        case createdAt = "createdAt"
        case metadata = "headers"
        case headers = "metadata"
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
