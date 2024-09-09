import Ably
import AblyChat
import AsyncAlgorithms

struct MockMessageSubscription: Sendable, AsyncSequence {
    typealias Merged = AsyncMerge2Sequence<AsyncMapSequence<AsyncTimerSequence<ContinuousClock>, Message>, AsyncStream<MockMessageSubscription.Element>>

    typealias Element = Message
    typealias AsyncIterator = Merged.AsyncIterator

    let clientID: String
    let roomID: String

    private let continuation: AsyncStream<Element>.Continuation
    private let merged: Merged

    static func createMessage(params: SendMessageParams, roomID: String, clientID: String) -> Message {
        return Message(timeserial: "\(Date().timeIntervalSince1970)",
                              clientID: clientID,
                              roomID: roomID,
                              text: params.text,
                              createdAt: Date(),
                              metadata: params.metadata ?? [:],
                              headers: params.headers ?? [:])
    }

    func emit(message params: SendMessageParams, clientID: String) -> Message {
        let message = MockMessageSubscription.createMessage(params: params, roomID: roomID, clientID: clientID)
        continuation.yield(message)
        return message
    }

    func makeAsyncIterator() -> AsyncIterator {
        merged.makeAsyncIterator()
    }
    
    init(clientID: String, roomID: String) {
        self.clientID = clientID
        self.roomID = roomID

        let timer: AsyncTimerSequence<ContinuousClock> = .init(interval: .seconds(3), clock: .init())
        let timedMessages = timer.map { _ in
            MockMessageSubscription.createMessage(params: SendMessageParams(text: MockStrings.randomPhrase()), roomID: roomID, clientID: MockStrings.names.randomElement()!)
        }

        let (stream, continuation) = AsyncStream.makeStream(of: Element.self, bufferingPolicy: .unbounded)
        self.continuation = continuation

        merged = merge(timedMessages, stream)
    }
}

struct MockReactionSubscription: Sendable, AsyncSequence {
    typealias Element = Reaction
    typealias AsyncIterator = AsyncStream<Element>.Iterator
    
    let clientID: String
    let roomID: String
    
    private let stream: AsyncStream<Element>
    private let continuation: AsyncStream<Element>.Continuation
    
    func emit(reaction params: RoomReactionParams) {
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
                emit(reaction: RoomReactionParams(type: ReactionType.allCases.randomElement()!.rawValue))
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
    
    func emitPresenceEvent(clientID: String, event: PresenceEventType) {
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
                emitPresenceEvent(clientID: MockStrings.names.randomElement()!, event: [.enter, .leave].randomElement()!)
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
