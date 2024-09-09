@testable import AblyChat

final class MockInternalLogger: InternalLogger, @unchecked Sendable {
    @SynchronizedAccess var logArguments: (message: String, level: LogLevel, codeLocation: CodeLocation)?

    func log(message: String, level: LogLevel, codeLocation: CodeLocation) {
        logArguments = (message: message, level: level, codeLocation: codeLocation)
    }
}
