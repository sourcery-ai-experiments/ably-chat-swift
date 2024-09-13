import AblyChat

final class MockLogHandler: LogHandler, @unchecked Sendable {
    @SynchronizedAccess var logArguments: (message: String, level: LogLevel, context: LogContext?)?

    func log(message: String, level: LogLevel, context: LogContext?) {
        logArguments = (message: message, level: level, context: context)
    }
}
