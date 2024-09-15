import AblyChat
import SwiftUI

@MainActor
struct ContentView: View {
    
    @State private var chatClient = MockChatClient(
        realtime: MockRealtime.create(),
        clientOptions: ClientOptions()
    )
    
    @State private var title = "Room: "
    @State private var messages = [BasicListItem]()
    @State private var reactions = ""
    @State private var newMessage = ""
    
    private func room() async -> Room {
        try! await chatClient.rooms.get(roomID: "Demo", options: .init())
    }
    
    private var sendTitle: String {
        newMessage.isEmpty ? ReactionType.like.emoji : "Send"
    }
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .padding(5)
            Text(reactions)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(5)
            List(messages, id: \.id) { item in
                MessageBasicView(item: item)
                    .flip()
            }
            .flip()
            .listStyle(PlainListStyle())
            HStack {
                TextField("Type a message...", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    if newMessage.isEmpty {
                        Task {
                            try await sendReaction(type: ReactionType.like.rawValue)
                        }
                    } else {
                        Task {
                            try await sendMessage()
                        }
                    }
                }) {
#if os(iOS)
                    Text(sendTitle)
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.blue)
                        .cornerRadius(15)
#elseif os(macOS)
                    Text(sendTitle)
#endif
                }
            }
            .padding(.bottom, 10)
            .padding(.horizontal, 12)
            .task { await showMessages() }
            .task { await showReactions() }
            .task { await showPresence() }
            .task { await showTypings() }
            .task { await setDefaultTitle() }
        }
    }
    
    func setDefaultTitle() async {
        title = await "Room: \(room().roomID)"
    }
    
    func showMessages() async {
        for await message in await room().messages.subscribe(bufferingPolicy: .unbounded) {
            withAnimation {
                messages.insert(BasicListItem(id: message.timeserial, title: message.clientID, text: message.text), at: 0)
            }
        }
    }
    
    func showReactions() async {
        for await reaction in await room().reactions.subscribe(bufferingPolicy: .unbounded) {
            withAnimation {
                reactions.append(reaction.displayedText)
            }
        }
    }
    
    func showPresence() async {
        for await event in await room().presence.subscribe(events: [.enter, .leave]) {
            withAnimation {
                messages.insert(BasicListItem(id: UUID().uuidString, title: "System", text: event.clientID + " \(event.action.displayedText)"), at: 0)
            }
        }
    }
    
    func showTypings() async {
        for await typing in await room().typing.subscribe(bufferingPolicy: .unbounded) {
            withAnimation {
                title = "Typing: \(typing.currentlyTyping.joined(separator: ", "))"
                Task {
                    try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
                    await setDefaultTitle()
                }
            }
        }
    }
    
    func sendMessage() async throws {
        guard !newMessage.isEmpty else { return }
        let _ = try await room().messages.send(params: .init(text: newMessage))
        newMessage = ""
    }
    
    func sendReaction(type: String) async throws {
        try await room().reactions.send(params: .init(type: type))
    }
}

struct BasicListItem {
    var id: String
    var title: String
    var text: String
}

struct MessageBasicView: View {
    var item: BasicListItem
    
    var body: some View {
        HStack {
            VStack {
                Text("\(item.title):")
                    .foregroundColor(.blue)
                    .bold()
                Spacer()
            }
            VStack {
                Text(item.text)
                Spacer()
            }
        }
        .listRowSeparator(.hidden)
    }
}

extension View {
    func flip() -> some View {
        return self
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}

#Preview {
    ContentView()
}

extension PresenceEventType {
    
    var displayedText: String {
        switch self {
        case .enter:
            return "has entered the room"
        case .leave:
            return "has left the room"
        case .present:
            return "has presented at the room"
        case .update:
            return "has updated presence"
        }
    }
}
