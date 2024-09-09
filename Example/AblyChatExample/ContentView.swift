import AblyChat
import SwiftUI

extension MockChatClient {
    static let shared = MockChatClient(realtime: MockRealtime.create(), clientOptions: .init())
}

@MainActor
struct ContentView: View {
    
    @State private var title = "Room: "
    @State private var messages = [BasicListItem]()
    @State private var reactions = ""
    @State private var newMessage = ""
    
    private func room() async -> Room {
        try! await MockChatClient.shared.rooms.get(roomID: "Demo", options: .init())
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
                    Task {
                        try await sendMessage()
                    }
                }) {
#if os(iOS)
                    Text("Send")
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.blue)
                        .cornerRadius(15)
#elseif os(macOS)
                    Text("Send")
#endif
                }
                Button(action: {
                    Task {
                        try await sendReaction(type: ReactionType.like.rawValue)
                    }
                }) {
                    Text(ReactionType.like.emoji)
                }
            }
            .padding(.bottom, 10)
            .padding(.horizontal, 12)
            .task {
                await setDefaultTitle()
            }
            .task {
                for await message in await room().messages.subscribe(bufferingPolicy: .unbounded) {
                    withAnimation {
                        messages.insert(BasicListItem(id: message.timeserial, title: message.clientID, text: message.text), at: 0)
                    }
                }
            }
            .task {
                for await reaction in await room().reactions.subscribe(bufferingPolicy: .unbounded) {
                    withAnimation {
                        reactions.append(reaction.displayedText)
                    }
                }
            }
            .task {
                for await event in await room().presence.subscribe(events: [.enter, .leave]) {
                    withAnimation {
                        messages.insert(BasicListItem(id: UUID().uuidString, title: "System", text: event.clientID + " \(event.action.displayedText)"), at: 0)
                    }
                }
            }
            .task {
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
        }
    }
    
    func setDefaultTitle() async {
        title = await "Room: \(room().roomID)"
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
