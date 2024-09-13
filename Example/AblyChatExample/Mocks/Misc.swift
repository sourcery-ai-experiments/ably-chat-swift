import Ably
import AblyChat

final class MockMessagesPaginatedResult: PaginatedResult {
    typealias T = Message
    
    let clientID: String
    let roomID: String
    
    var items: [T] {
        [
            Message(timeserial: "\(Date().timeIntervalSince1970)",
                           clientID: self.clientID,
                           roomID: self.roomID,
                           text: MockStrings.randomPhrase(),
                           createdAt: Date(),
                           metadata: [:],
                           headers: [:])
        ]
    }
    
    var hasNext: Bool { fatalError("Not implemented") }

    var isLast: Bool { fatalError("Not implemented") }

    var next: (any PaginatedResult<T>)? { fatalError("Not implemented") }

    var first: any PaginatedResult<T> { fatalError("Not implemented") }

    var current: any PaginatedResult<T> { fatalError("Not implemented") }

    init(clientID: String, roomID: String) {
        self.clientID = clientID
        self.roomID = roomID
    }
}

class MockStrings {
    
    static let names = [ "Alice", "Bob", "Charlie", "Dave", "Eve" ]
    
    static func randomWord(length: Int = Int.random(in: 1...10)) -> String {
        var word = ""
        for _ in 0..<length {
            let char = String(format: "%c", Int.random(in: 97..<123))
            word += char
        }
        return word
    }
    
    static func randomPhrase(length: Int = Int.random(in: 1...10)) -> String {
        var phrase = ""
        for _ in 0..<length {
            phrase += randomWord() + " "
        }
        phrase += Int.random(in: 1...100) % 5 == 0 ? "😆" : ""
        return phrase.count % 33 == 0 ? "Bingo! 😂" : phrase
    }
}

enum ReactionType: String, CaseIterable {
    case like, dislike, lol, rofl, ok, idk
    
    var emoji: String {
        switch self {
        case .like:
            return "👍"
        case .dislike:
            return "👎"
        case .lol:
            return "😆"
        case .rofl:
            return "😂"
        case .ok:
            return "👌"
        default:
            return "🤷‍♀️"
        }
    }
}

extension Reaction {
    
    var displayedText: String {
        ReactionType(rawValue: type)?.emoji ?? ReactionType.idk.emoji
    }
}
