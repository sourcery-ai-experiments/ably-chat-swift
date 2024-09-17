import Ably

func getChannel(_ name: String, realtime: RealtimeClient, opts: ARTRealtimeChannelOptions? = nil) -> any RealtimeChannelProtocol {
    // Merge opts and DEFAULT_CHANNEL_OPTIONS
    var resolvedOptions = ARTRealtimeChannelOptions()
    if let opts = opts {
        resolvedOptions = opts
    }
    
    resolvedOptions.params = opts?.params?.merging(
        DEFAULT_CHANNEL_OPTIONS.params ?? [:],
        uniquingKeysWith: { (_, new) in new }
    )

    return realtime.channels.get(name, options: resolvedOptions)
}

// Get the channel name for the chat messages channel
func messagesChannelName(roomId: String) -> String {
    return "\(roomId)::$chat::$chatMessages"
}

