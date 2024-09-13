import Foundation

// Timeserial Protocol
protocol Timeserial: Sendable {
    var seriesId: String { get }
    var timestamp: Int { get }
    var counter: Int { get }
    var index: Int? { get }

    func toString() -> String
    func before(_ timeserial: Timeserial) -> Bool
    func after(_ timeserial: Timeserial) -> Bool
    func equal(_ timeserial: Timeserial) -> Bool
}

// DefaultTimeserial Class
final class DefaultTimeserial: Timeserial {
    let seriesId: String
    let timestamp: Int
    let counter: Int
    let index: Int?

    private init(seriesId: String, timestamp: Int, counter: Int, index: Int?) {
        self.seriesId = seriesId
        self.timestamp = timestamp
        self.counter = counter
        self.index = index
    }

    // Convert to String
    func toString() -> String {
        var result = "\(seriesId)@\(timestamp)-\(counter)"
        if let idx = index {
            result += ":\(idx)"
        }
        return result
    }

    // Static method to parse a timeserial string
    static func calculateTimeserial(from timeserial: String) throws -> Timeserial {
        let components = timeserial.split(separator: "@")
        guard components.count == 2, let rest = components.last else {
            throw NSError(domain: "InvalidTimeserial", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid timeserial format"])
        }

        let seriesId = String(components[0])
        let parts = rest.split(separator: "-")
        guard parts.count == 2 else {
            throw NSError(domain: "InvalidTimeserial", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid timeserial format"])
        }

        let timestamp = Int(parts[0]) ?? 0
        let counterAndIndex = parts[1].split(separator: ":")
        let counter = Int(counterAndIndex[0]) ?? 0
        let index = counterAndIndex.count > 1 ? Int(counterAndIndex[1]) : nil

        return DefaultTimeserial(seriesId: seriesId, timestamp: timestamp, counter: counter, index: index)
    }

    // Compare timeserials
    private func timeserialCompare(_ other: Timeserial) -> Int {
        // Compare timestamps
        let timestampDiff = self.timestamp - other.timestamp
        if timestampDiff != 0 {
            return timestampDiff
        }

        // Compare counters
        let counterDiff = self.counter - other.counter
        if counterDiff != 0 {
            return counterDiff
        }

        // Compare seriesId lexicographically
        if self.seriesId != other.seriesId {
            return self.seriesId < other.seriesId ? -1 : 1
        }

        // Compare index if present
        if let idx1 = self.index, let idx2 = other.index {
            return idx1 - idx2
        }

        return 0
    }

    // Check if this timeserial is before the given timeserial
    func before(_ timeserial: Timeserial) -> Bool {
        return timeserialCompare(timeserial) < 0
    }

    // Check if this timeserial is after the given timeserial
    func after(_ timeserial: Timeserial) -> Bool {
        return timeserialCompare(timeserial) > 0
    }

    // Check if this timeserial is equal to the given timeserial
    func equal(_ timeserial: Timeserial) -> Bool {
        return timeserialCompare(timeserial) == 0
    }
}
