import Ably
import AblyChat

struct MockMessageSubscription: Sendable, AsyncSequence {
    typealias Element = Message
    typealias AsyncIterator = AsyncStream<Element>.Iterator
    
    let clientID: String
    let roomID: String
    
    private let stream: AsyncStream<Element>
    private let continuation: AsyncStream<Element>.Continuation
    
    func emit(message params: SendMessageParams, clientID: String) -> Message {
        let message = Message(timeserial: "\(Date().timeIntervalSince1970)",
                              clientID: clientID,
                              roomID: roomID,
                              text: params.text,
                              createdAt: Date(),
                              metadata: params.metadata ?? [:],
                              headers: params.headers ?? [:])
        continuation.yield(message)
        return message
    }
    
    func emitMessages() {
        Task {
            while (true) {
                try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
                _ = emit(message: SendMessageParams(text: MockStrings.randomPhrase()), clientID: MockStrings.names.randomElement()!)
            }
        }
    }
    
    func makeAsyncIterator() -> AsyncIterator {
        stream.makeAsyncIterator()
    }
    
    init(clientID: String, roomID: String) {
        self.clientID = clientID
        self.roomID = roomID
        let (stream, continuation) = AsyncStream.makeStream(of: Element.self, bufferingPolicy: .unbounded)
        self.stream = stream
        self.continuation = continuation
        emitMessages()
    }
}

struct MockReactionSubscription: Sendable, AsyncSequence {
    typealias Element = Reaction
    typealias AsyncIterator = AsyncStream<Element>.Iterator
    
    let clientID: String
    let roomID: String
    
    private let stream: AsyncStream<Element>
    private let continuation: AsyncStream<Element>.Continuation
    
    func emit(reaction params: SendReactionParams) {
        let reaction = Reaction(type: params.type,
                               metadata: [:],
                               headers: [:],
                               createdAt: Date(),
                               clientID: self.clientID,
                               isSelf: false)
        continuation.yield(reaction)
    }
    
    func emitReactions() {
        Task {
            while (true) {
                try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
                emit(reaction: SendReactionParams(type: ReactionType.allCases.randomElement()!.rawValue))
            }
        }
    }
    
    func makeAsyncIterator() -> AsyncIterator {
        stream.makeAsyncIterator()
    }
    
    init(clientID: String, roomID: String) {
        self.clientID = clientID
        self.roomID = roomID
        let (stream, continuation) = AsyncStream.makeStream(of: Element.self, bufferingPolicy: .unbounded)
        self.stream = stream
        self.continuation = continuation
        emitReactions()
    }
}

struct MockTypingSubscription: Sendable, AsyncSequence {
    typealias Element = TypingEvent
    typealias AsyncIterator = AsyncStream<Element>.Iterator
    
    let clientID: String
    let roomID: String
    
    private let stream: AsyncStream<Element>
    private let continuation: AsyncStream<Element>.Continuation
    
    func emit(names: Set<String>) {
        let typing = TypingEvent(currentlyTyping: names)
        continuation.yield(typing)
    }
    
    func emitTypings() {
        Task {
            while (true) {
                try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                emit(names: [MockStrings.names.randomElement()!, MockStrings.names.randomElement()!])
            }
        }
    }
    
    func makeAsyncIterator() -> AsyncIterator {
        stream.makeAsyncIterator()
    }
    
    init(clientID: String, roomID: String) {
        self.clientID = clientID
        self.roomID = roomID
        let (stream, continuation) = AsyncStream.makeStream(of: Element.self, bufferingPolicy: .unbounded)
        self.stream = stream
        self.continuation = continuation
        emitTypings()
    }
}

struct MockPresenceSubscription: Sendable, AsyncSequence {
    typealias Element = PresenceEvent
    typealias AsyncIterator = AsyncStream<Element>.Iterator
    
    let clientID: String
    let roomID: String
    
    private let stream: AsyncStream<Element>
    private let continuation: AsyncStream<Element>.Continuation
    
    func emitPresenceEvent(_ event: PresenceEventType, clientID: String) {
        let presence = PresenceEvent(action: event,
                                     clientID: clientID,
                                     timestamp: Date(),
                                     data: nil)
        continuation.yield(presence)
    }
    
    func emitPresenceEvents() {
        Task {
            while (true) {
                try? await Task.sleep(nanoseconds: 5 * 1_000_000_000)
                emitPresenceEvent([.enter, .leave].randomElement()!, clientID: MockStrings.names.randomElement()!)
            }
        }
    }
    
    func makeAsyncIterator() -> AsyncIterator {
        stream.makeAsyncIterator()
    }
    
    init(clientID: String, roomID: String) {
        self.clientID = clientID
        self.roomID = roomID
        let (stream, continuation) = AsyncStream.makeStream(of: Element.self, bufferingPolicy: .unbounded)
        self.stream = stream
        self.continuation = continuation
        emitPresenceEvents()
    }
}
