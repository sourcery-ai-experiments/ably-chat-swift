// TODO: (https://github.com/ably-labs/ably-chat-swift/issues/13): try to improve this type

import Foundation

// Define protocol for types that are Sendable and Encodable
public protocol SendableEncodable: Sendable, Codable, Hashable {}

// Example conforming type
public struct MetadataValue: SendableEncodable {
    let value: String
    
    enum CodingKeys: String, CodingKey {
        case value
    }
    
    init(value: String) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(String.self, forKey: .value)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
    }
}

// Define Metadata type alias
public typealias Metadata = [String: MetadataValue?]

// Encoding Metadata
func encodeMetadata(metadata: Metadata) throws -> Data {
    let encoder = JSONEncoder()
    return try encoder.encode(metadata)
}

// Decoding Metadata
func decodeMetadata(from data: Data) throws -> Metadata {
    let decoder = JSONDecoder()
    return try decoder.decode(Metadata.self, from: data)
}
