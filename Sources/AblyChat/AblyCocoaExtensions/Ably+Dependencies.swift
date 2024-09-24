import Ably

// TODO: remove "@unchecked Sendable" once https://github.com/ably/ably-cocoa/issues/1962 done

// This @retroactive is needed to silence the Swift 6 compiler error "extension declares a conformance of imported type 'ARTRealtimeChannels' to imported protocol 'Sendable'; this will not behave correctly if the owners of 'Ably' introduce this conformance in the future (…) add '@retroactive' to silence this warning". I don’t fully understand the implications of this but don’t really mind since both libraries are in our control.
extension ARTRealtime: RealtimeClientProtocol, @retroactive @unchecked Sendable {}

extension ARTRealtimeChannels: RealtimeChannelsProtocol, @retroactive @unchecked Sendable {}

extension ARTRealtimeChannel: RealtimeChannelProtocol, @retroactive @unchecked Sendable {}
