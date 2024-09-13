import Ably

public protocol EmitsDiscontinuities {
    func subscribeToDiscontinuities() -> Subscription<ARTErrorInfo>
}

/**
 * Represents an object that has a channel and therefore may care about discontinuities.
 */
public protocol HandlesDiscontinuity {
    var channel: (any RealtimeChannelProtocol)? { get async }

//    var channel: RealtimeChannelProtocol? { get }
    /**
     * Called when a discontinuity is detected on the channel.
     * @param reason The error that caused the discontinuity.
     */
    func discontinuityDetected(reason: ARTErrorInfo?)
}
