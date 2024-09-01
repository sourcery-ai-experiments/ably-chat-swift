import AblyChat
import SwiftUI

extension MockChatClient {
    static let shared = MockChatClient(realtime: MockRealtime.create(), clientOptions: .init())
}

@MainActor
struct ContentView: View {
    
    @State private var title = "Room: "
    @State private var messages = [Message]()
    @State private var newMessage = ""
    
    private func room() async -> Room {
        try! await MockChatClient.shared.rooms.get(roomID: "Demo", options: .init())
    }
    
    var body: some View {
        VStack {
            Text(title).font(.headline)
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
            }
            .padding(.bottom, 10)
            .padding(.horizontal, 12)
            .task {
                let room = await room()
                title = "Room: \(room.roomID)"
                for await message in await room.messages.subscribe(bufferingPolicy: .unbounded) {
                    withAnimation {
                        messages.insert(message, at: 0)
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
        .padding(.leading, 5)
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
