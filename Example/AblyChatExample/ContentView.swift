import AblyChat
import SwiftUI

@MainActor
struct ContentView: View {

#if os(macOS)
    let screenWidth = NSScreen.main?.frame.width ?? 500
    let screenHeight = NSScreen.main?.frame.height ?? 500
#else
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
#endif

    @State private var chatClient = MockChatClient(
        realtime: MockRealtime.create(),
        clientOptions: ClientOptions()
    )
    
    @State private var title = "Room"
    @State private var messages = [BasicListItem]()
    @State private var reactions: [Reaction] = []
    @State private var newMessage = ""
    @State private var typingInfo = ""
    @State private var occupancyInfo = "Connections: 0"
    @State private var statusInfo = ""

    private func room() async -> Room {
        try! await chatClient.rooms.get(roomID: "Demo", options: .init())
    }
    
    private var sendTitle: String {
        newMessage.isEmpty ? ReactionType.like.emoji : "Send"
    }
    
    var body: some View {
        ZStack {
            VStack {
                Text(title)
                    .font(.headline)
                    .padding(5)
                HStack {
                    Text("")
                    Text(occupancyInfo)
                    Text(statusInfo)
                }
                .font(.footnote)
                .frame(height: 12)
                .padding(.horizontal, 8)
                List(messages, id: \.id) { item in
                    MessageBasicView(item: item)
                        .flip()
                }
                .flip()
                .listStyle(PlainListStyle())
                HStack {
                    TextField("Type a message...", text: $newMessage)
#if !os(tvOS)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
#endif
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
#else
                        Text(sendTitle)
#endif
                    }
                }
                .padding(.horizontal, 12)
                HStack {
                    Text(typingInfo)
                        .font(.footnote)
                    Spacer()
                }
                .frame(height: 12)
                .padding(.horizontal, 14)
                .padding(.bottom, 5)
            }
            ForEach(reactions) { reaction in
                Text(reaction.emoji)
                    .font(.largeTitle)
                    .position(x: reaction.xPosition, y: reaction.yPosition)
                    .scaleEffect(reaction.scale)
                    .opacity(reaction.opacity)
                    .rotationEffect(.degrees(reaction.rotationAngle))
                    .onAppear {
                        withAnimation(.easeOut(duration: reaction.duration)) {
                            moveReactionUp(reaction: reaction)
                        }
                        // Start rotation animation
                        withAnimation(Animation.linear(duration: reaction.duration).repeatForever(autoreverses: false)) {
                            startRotation(reaction: reaction)
                        }
                    }
            }
        }
        .task { await showMessages() }
        .task { await showReactions() }
        .task { await showPresence() }
        .task { await showTypings() }
        .task { await showOccupancy() }
        .task { await showRoomStatus() }
        .task { await setDefaultTitle() }
    }
    
    func setDefaultTitle() async {
        title = await "\(room().roomID)"
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
                showReaction(reaction.displayedText)
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
                typingInfo = "Typing: \(typing.currentlyTyping.joined(separator: ", "))..."
                Task {
                    try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
                    withAnimation {
                        typingInfo = ""
                    }
                }
            }
        }
    }
    
    func showOccupancy() async {
        for await event in await room().occupancy.subscribe(bufferingPolicy: .unbounded) {
            withAnimation {
                occupancyInfo = "Connections: \(event.presenceMembers) (\(event.connections))"
            }
        }
    }
    
    func showRoomStatus() async {
        for await status in await room().status.onChange(bufferingPolicy: .unbounded) {
            withAnimation {
                if status.current == .attaching {
                    statusInfo = "\(status.current)...".capitalized
                } else {
                    statusInfo = "\(status.current)".capitalized
                    if status.current == .attached {
                        Task {
                            try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
                            withAnimation {
                                statusInfo = ""
                            }
                        }
                    }
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

extension ContentView {
    
    struct Reaction: Identifiable {
        let id: UUID
        let emoji: String
        var xPosition: CGFloat
        var yPosition: CGFloat
        var scale: CGFloat
        var opacity: Double
        var rotationAngle: Double // New: stores the current rotation angle
        var rotationSpeed: Double // New: stores the random rotation speed
        var duration: Double
    }
    
    func showReaction(_ emoji: String) {
        let screenWidth = screenWidth
        let centerX = screenWidth / 2
        
        // Reduce the spread to 1/5th of the screen width
        let reducedSpreadRange = screenWidth / 5
        
        // Random x position now has a smaller range, centered around the middle of the screen
        let startXPosition = CGFloat.random(in: centerX - reducedSpreadRange...centerX + reducedSpreadRange)
        let randomRotationSpeed = Double.random(in: 30...360) // Random rotation speed
        let duration = Double.random(in: 2...4)

        let newReaction = Reaction(
            id: UUID(),
            emoji: emoji,
            xPosition: startXPosition,
            yPosition: screenHeight - 100,
            scale: 1.0,
            opacity: 1.0,
            rotationAngle: 0, // Initial angle
            rotationSpeed: randomRotationSpeed,
            duration: duration
        )

        reactions.append(newReaction)

        // Remove the reaction after the animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            reactions.removeAll { $0.id == newReaction.id }
        }
    }

    func moveReactionUp(reaction: Reaction) {
        if let index = reactions.firstIndex(where: { $0.id == reaction.id }) {
            reactions[index].yPosition = 0  // Move it to the top of the screen
            reactions[index].scale = 0.5    // Shrink
            reactions[index].opacity = 0.5  // Fade out
        }
    }

    func startRotation(reaction: Reaction) {
        if let index = reactions.firstIndex(where: { $0.id == reaction.id }) {
            reactions[index].rotationAngle += 360 // Continuous rotation over time
        }
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
#if !os(tvOS)
        .listRowSeparator(.hidden)
#endif
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
