import AblyChat
import SwiftUI

struct ContentView: View {
    /// Just used to check that we can successfully import and use the AblyChat library. TODO remove this once we start building the library
//    @State private var ablyChatClient = DefaultChatClient(
//        realtime: MockRealtime(key: ""),
//        clientOptions: ClientOptions()
//    )
    
    var room: Room {
        try! MockChatClient.shared.rooms.get(roomID: "Demo Room", options: .init())
    }
    
    // compiler doesn't allow to use `room` property here, needs to think about proper initialization
    @StateObject private var messagesClient = try! MockChatClient.shared.rooms.get(roomID: "Demo Room", options: .init()).messages as! MockMessages
    
    @State private var messages = [Message]()
    @State private var newMessage: String = .randomPhrase()
    
    var body: some View {
        VStack {
            Text(messagesClient.roomID).font(.headline)
            List(messagesClient.log + messages) { message in
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
                for await message in room.messages.subscribe(bufferingPolicy: .unbounded) {
                    withAnimation {
                        messages.insert(message, at: 0)
                    }
                }
            }
        }
    }
    
    @MainActor func sendMessage() async throws {
        guard !newMessage.isEmpty else { return }
        _ = try await messagesClient.send(params: .init(text: newMessage))
        newMessage = .randomPhrase()
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
    // Flipping views for nice and smooth calculationless scroll to bottom. Have no idea why apple still don't have a scroll mode for that.
    // Works like a charm on iOS, for macOS a bit glitchy.
    func flip() -> some View {
        return self
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}

//struct MessageBubbleView: View {
//    var message: Message
//    
//    @Environment(\.colorScheme) var colorScheme
//    
//    var body: some View {
//        HStack {
//            if message.isCurrentUser {
//                Spacer()
//            }
//            VStack(alignment: message.isCurrentUser ? .trailing : .leading) {
//                Text(message.sender)
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                
//                Text(message.text)
//                    .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
//                    .background(message.isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
//                    .foregroundColor(message.isCurrentUser || colorScheme == .dark ? .white : .black)
//                    .cornerRadius(15)
//                    .frame(minWidth: 60)
//            }
//        }
//        .padding(message.isCurrentUser ? .leading : .trailing, 60)
//        .listRowSeparator(.hidden)
//        .frame(minWidth: 120)
//    }
//}

#Preview {
    ContentView()
}
