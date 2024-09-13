//
//  ContentView.swift
//  chatTest
//
//  Created by Umair on 09/09/2024.
//

import SwiftUI
import AblyChat
import Ably

struct MessageCell: View {
    var contentMessage: String
    var isCurrentUser: Bool
    
    var body: some View {
        Text(contentMessage)
            .padding(12)
            .foregroundColor(isCurrentUser ? Color.white : Color.black)
            .background(isCurrentUser ? Color.blue : Color(UIColor.systemGray6 ))
            .cornerRadius(12)
    }
}

struct MessageView : View {
    var currentMessage: Message
    
    var body: some View {
        HStack(alignment: .bottom) {
            if let clientId = currentMessage.clientID {
                if clientId == "Umair" {
                    Spacer()
                } else {

                }
                MessageCell(contentMessage: currentMessage.text,
                            isCurrentUser: clientId == "Umair")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

@MainActor
struct ContentView: View {
    @State private var messages: [Message] = [] // Store the chat messages
    @State private var newMessage: String = "" // Store the message user is typing
    @State private var room: Room? // Keep track of the chat room

    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(messages, id: \.self) { message in
                        MessageView(currentMessage: message)
                            .id(message)
                    }
                }
                .onChange(of: messages.count) {
                    withAnimation {
                        proxy.scrollTo(messages.last, anchor: .bottom)
                    }
                    
                }.onAppear {
                    withAnimation {
                        proxy.scrollTo(messages.last, anchor: .bottom)
                    }
                }

            }
            
            // send new message
            HStack {
                TextField("Send a message", text: $newMessage)
                    .textFieldStyle(.roundedBorder)
                Button(action: sendMessage)   {
                    Image(systemName: "paperplane")
                }
            }
            .padding()
        }
            .onAppear {
                Task {
                    await startChat()
                }
            }
    }
}
    
    var clientOptions: ARTClientOptions {
        let options = ARTClientOptions()
        options.clientId = "Umair"
        options.key = "4dypbA.0N1o5A:I0GPeR-Sh15rJwPLPURx9kE27hwPqAVZnjcVO3T2BlU"
        return options
    }
    
    // This is the modified async function to start the chat
    func startChat() async {
        let realtime = ARTRealtime(options: clientOptions)
        let rest = ARTRest(options: clientOptions)
    
        let chatClient = DefaultChatClient(
            realtime: realtime,
            rest: rest,
            clientOptions: nil)

        do {
            // Get the chat room
            self.room = try await chatClient.rooms.get(roomID: "umairsDemoRoom1", options: .init())
            try await room?.attach()

            let _ = try await room?.messages.subscribe(bufferingPolicy: .unbounded, listener: .init(id: UUID().uuidString, listener: { listener in
                Task {
                    messages.append(listener.message)
                }
            }))

        } catch {
            print("Error starting chat: \(error)")
        }
        
        do {
            // Fetch the chat messages
            let fetchedMessages = try await room?.messages.get(options: .init(orderBy: .oldestFirst))
            
            // Update the UI with the messages
            messages = fetchedMessages?.items.map { $0 } ?? [] // Assuming message has 'content' field
        }
        catch {
            print("Failed to get messages: \(error)")
        }
    }
    
    // Function to send a message
    func sendMessage() {
        guard !newMessage.isEmpty else { return }
        Task {
            do {
                // Assuming the room object has a method to send messages
                _ = try await room?.messages.send(params: .init(text: newMessage))

                // Clear the text field after sending
                newMessage = ""

            } catch {
                print("Error sending message: \(error)")
            }
        }
    }
}


#Preview {
    ContentView()
}

