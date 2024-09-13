import Ably

// Update this when you release a new version

// Version information
public let VERSION = "0.1.0"

// Channel options agent string
public let CHANNEL_OPTIONS_AGENT_STRING = "chat-ios/\(VERSION)"

// Default channel options
public let DEFAULT_CHANNEL_OPTIONS: ARTRealtimeChannelOptions = {
    let options = ARTRealtimeChannelOptions()
    options.params = ["agent": CHANNEL_OPTIONS_AGENT_STRING]
    return options
}()
