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
                           text: String.randomPhrase(),
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

final class MockPresencePaginatedResult: PaginatedResult {
    typealias T = PresenceMember
    
    private let members: [String]
    
    init(members: [String]) {
        self.members = members
    }
    
    var items: [T] {
        members.map { name in
            PresenceMember(clientID: name,
                           data: ["foo": "bar"],
                           action: .present,
                           extras: nil,
                           updatedAt: Date())
        }
    }
    
    var hasNext: Bool { fatalError("Not implemented") }

    var isLast: Bool { fatalError("Not implemented") }

    var next: (any PaginatedResult<T>)? { fatalError("Not implemented") }

    var first: any PaginatedResult<T> { fatalError("Not implemented") }

    var current: any PaginatedResult<T> { fatalError("Not implemented") }
}

extension String {
    
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
