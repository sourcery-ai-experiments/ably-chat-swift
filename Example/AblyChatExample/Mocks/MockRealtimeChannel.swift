import Ably

/// A mock implementation of `ARTRealtimeChannelProtocol`. It only exists so that we can construct an instance of `MockMessages` without needing to create a proper `ARTRealtimeChannel` instance.
final class MockRealtimeChannel: NSObject, ARTRealtimeChannelProtocol, Sendable {
    let name: String = ""

    var state: ARTRealtimeChannelState { fatalError("Not implemented") }
    
    var errorReason: ARTErrorInfo? { fatalError("Not implemented") }
    
    var options: ARTRealtimeChannelOptions? { fatalError("Not implemented") }
    
    func attach() {
        fatalError("Not implemented")
    }
    
    func attach(_ callback: ARTCallback? = nil) {
        fatalError("Not implemented")
    }
    
    func detach() {
        fatalError("Not implemented")
    }
    
    func detach(_ callback: ARTCallback? = nil) {
        fatalError("Not implemented")
    }
    
    func subscribe(_ callback: @escaping ARTMessageCallback) -> ARTEventListener? {
        fatalError("Not implemented")
    }
    
    func subscribe(attachCallback onAttach: ARTCallback?, callback: @escaping ARTMessageCallback) -> ARTEventListener? {
        fatalError("Not implemented")
    }
    
    func subscribe(_ name: String, callback: @escaping ARTMessageCallback) -> ARTEventListener? {
        fatalError("Not implemented")
    }
    
    func subscribe(_ name: String, onAttach: ARTCallback?, callback: @escaping ARTMessageCallback) -> ARTEventListener? {
        fatalError("Not implemented")
    }
    
    func unsubscribe() {
        fatalError("Not implemented")
    }
    
    func unsubscribe(_ listener: ARTEventListener?) {
        fatalError("Not implemented")
    }
    
    func unsubscribe(_ name: String, listener: ARTEventListener?) {
        fatalError("Not implemented")
    }
    
    func history(_ query: ARTRealtimeHistoryQuery?, callback: @escaping ARTPaginatedMessagesCallback) throws {
        fatalError("Not implemented")
    }
    
    func setOptions(_ options: ARTRealtimeChannelOptions?, callback: ARTCallback? = nil) {
        fatalError("Not implemented")
    }
    
    func on(_ event: ARTChannelEvent, callback cb: @escaping (ARTChannelStateChange) -> Void) -> ARTEventListener {
        fatalError("Not implemented")
    }
    
    func on(_ cb: @escaping (ARTChannelStateChange) -> Void) -> ARTEventListener {
        fatalError("Not implemented")
    }
    
    func once(_ event: ARTChannelEvent, callback cb: @escaping (ARTChannelStateChange) -> Void) -> ARTEventListener {
        fatalError("Not implemented")
    }
    
    func once(_ cb: @escaping (ARTChannelStateChange) -> Void) -> ARTEventListener {
        fatalError("Not implemented")
    }
    
    func off(_ event: ARTChannelEvent, listener: ARTEventListener) {
        fatalError("Not implemented")
    }
    
    func off(_ listener: ARTEventListener) {
        fatalError("Not implemented")
    }
    
    func off() {
        fatalError("Not implemented")
    }
    
    func publish(_ name: String?, data: Any?) {
        fatalError("Not implemented")
    }
    
    func publish(_ name: String?, data: Any?, callback: ARTCallback? = nil) {
        fatalError("Not implemented")
    }
    
    func publish(_ name: String?, data: Any?, clientId: String) {
        fatalError("Not implemented")
    }
    
    func publish(_ name: String?, data: Any?, clientId: String, callback: ARTCallback? = nil) {
        fatalError("Not implemented")
    }
    
    func publish(_ name: String?, data: Any?, extras: (any ARTJsonCompatible)?) {
        fatalError("Not implemented")
    }
    
    func publish(_ name: String?, data: Any?, extras: (any ARTJsonCompatible)?, callback: ARTCallback? = nil) {
        fatalError("Not implemented")
    }
    
    func publish(_ name: String?, data: Any?, clientId: String, extras: (any ARTJsonCompatible)?) {
        fatalError("Not implemented")
    }
    
    func publish(_ name: String?, data: Any?, clientId: String, extras: (any ARTJsonCompatible)?, callback: ARTCallback? = nil) {
        fatalError("Not implemented")
    }
    
    func publish(_ messages: [ARTMessage]) {
        fatalError("Not implemented")
    }
    
    func publish(_ messages: [ARTMessage], callback: ARTCallback? = nil) {
        fatalError("Not implemented")
    }
    
    func history(_ callback: @escaping ARTPaginatedMessagesCallback) {
        fatalError("Not implemented")
    }
}
