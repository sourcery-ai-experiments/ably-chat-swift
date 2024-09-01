import AblyChat
import SwiftUI

extension MockChatClient {
    static let shared = MockChatClient(realtime: MockRealtime.create(), clientOptions: .init())
}

@MainActor
struct ContentView: View {
    
    @State private var title = "Room: "
    @State private var messages = [Message]()
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
            List(messages, id: \.timeserial) { message in
                MessageBasicView(message: message)
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
                        try await sendReaction(type: "like")
                    }
                }) {
                    Text("👍")
                }
            }
            .padding(.bottom, 10)
            .padding(.horizontal, 12)
            .task {
                title = await "Room: \(room().roomID)"
            }
            .task {
                for await message in await room().messages.subscribe(bufferingPolicy: .unbounded) {
                    withAnimation {
                        messages.insert(message, at: 0)
                    }
                }
            }
            .task {
                for await reaction in await room().reactions.subscribe(bufferingPolicy: .unbounded) {
                    withAnimation {
                        reactions.append(reaction.type == "like" ? "👍" : "🤷")
                    }
                }
            }
        }
    }
    
    func sendMessage() async throws {
        guard !newMessage.isEmpty else { return }
        let message = try await room().messages.send(params: .init(text: newMessage))
        withAnimation {
            messages.insert(message, at: 0)
        }
        newMessage = ""
    }
    
    func sendReaction(type: String) async throws {
        try await room().reactions.send(params: .init(type: type))
        withAnimation {
            reactions.append("👍")
        }
    }
}

struct MessageBasicView: View {
    var message: Message
    
    var body: some View {
        HStack {
            VStack {
                Text("\(message.clientID):")
                    .foregroundColor(.blue)
                    .bold()
                Spacer()
            }
            VStack {
                Text(message.text)
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
