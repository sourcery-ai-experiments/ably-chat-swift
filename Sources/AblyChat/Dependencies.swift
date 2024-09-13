import Ably

/// Expresses the requirements of the Ably realtime client that is supplied to the Chat SDK.
///
/// The `ARTRealtime` class from the ably-cocoa SDK implements this protocol.
public protocol RealtimeClientProtocol: ARTRealtimeProtocol, Sendable {
    associatedtype Channels: RealtimeChannelsProtocol

    // It’s not clear to me why ARTRealtimeProtocol doesn’t include this property. I briefly tried adding it but ran into compilation failures that it wasn’t immediately obvious how to fix.
    var channels: Channels { get }
}

/// Expresses the requirements of the object returned by ``RealtimeClientProtocol.channels``.
public protocol RealtimeChannelsProtocol: ARTRealtimeChannelsProtocol, Sendable {
    associatedtype Channel: RealtimeChannelProtocol

    // It’s not clear to me why ARTRealtimeChannelsProtocol doesn’t include this property (https://github.com/ably/ably-cocoa/issues/1968).
    func get(_ name: String, options: ARTRealtimeChannelOptions) -> Channel
    func get(_ name: String) -> Channel
}

/// Expresses the requirements of the object returned by ``RealtimeChannelsProtocol.get(_:)``.
public protocol RealtimeChannelProtocol: ARTRealtimeChannelProtocol, Sendable {}
