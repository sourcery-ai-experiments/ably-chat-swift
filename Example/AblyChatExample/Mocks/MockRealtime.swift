import Ably

/// A mock implementation of `ARTRealtimeProtocol`. It only exists so that we can construct an instance of `DefaultChatClient` without needing to create a proper `ARTRealtime` instance (which we can’t yet do because we don’t have a method for inserting an API key into the example app). TODO remove this once we start building the example app
final class MockRealtime: NSObject, ARTRealtimeProtocol, Sendable {
    var device: ARTLocalDevice {
        fatalError("Not implemented")
    }

    var clientId: String? {
        fatalError("Not implemented")
    }

    required init(options _: ARTClientOptions) {}

    required init(key _: String) {}

    required init(token _: String) {}

    /**
     Creates an instance of MockRealtime.

     This exists to give a convenient way to create an instance, because `init` is marked as unavailable in `ARTRealtimeProtocol`.
     */
    static func create() -> MockRealtime {
        MockRealtime(key: "")
    }

    func time(_: @escaping ARTDateTimeCallback) {
        fatalError("Not implemented")
    }

    func ping(_: @escaping ARTCallback) {
        fatalError("Not implemented")
    }

    func stats(_: @escaping ARTPaginatedStatsCallback) -> Bool {
        fatalError("Not implemented")
    }

    func stats(_: ARTStatsQuery?, callback _: @escaping ARTPaginatedStatsCallback) throws {
        fatalError("Not implemented")
    }

    func connect() {
        fatalError("Not implemented")
    }

    func close() {
        fatalError("Not implemented")
    }
}
