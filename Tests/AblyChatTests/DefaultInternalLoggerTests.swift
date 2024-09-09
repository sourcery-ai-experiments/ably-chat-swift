@testable import AblyChat
import XCTest

class DefaultInternalLoggerTests: XCTestCase {
    func test_defaults() {
        let logger = DefaultInternalLogger(logHandler: nil, logLevel: nil)

        XCTAssertTrue(logger.logHandler is DefaultLogHandler)
        XCTAssertEqual(logger.logLevel, .error)
    }

    func test_log() throws {
        // Given: A DefaultInternalLogger instance
        let logHandler = MockLogHandler()
        let logger = DefaultInternalLogger(logHandler: logHandler, logLevel: nil)

        // When: `log(message:level:codeLocation:)` is called on it
        logger.log(
            message: "Hello",
            level: .error, // arbitrary
            codeLocation: .init(fileID: "Ably/Room.swift", line: 123)
        )

        // Then: It calls log(…) on the underlying logger, interpolating the code location into the message and passing through the level
        let logArguments = try XCTUnwrap(logHandler.logArguments)
        XCTAssertEqual(logArguments.message, "(Ably/Room.swift:123) Hello")
        XCTAssertEqual(logArguments.level, .error)
        XCTAssertNil(logArguments.context)
    }

    func test_log_whenLogLevelArgumentIsLessSevereThanLogLevelProperty_itDoesNotLog() {
        // Given: A DefaultInternalLogger instance
        let logHandler = MockLogHandler()
        let logger = DefaultInternalLogger(
            logHandler: logHandler,
            logLevel: .info // arbitrary
        )

        // When: `log(message:level:codeLocation:)` is called on it, with `level` less severe than that of the instance
        logger.log(
            message: "Hello",
            level: .debug,
            codeLocation: .init(fileID: "", line: 0)
        )

        // Then: It does not call `log(…)` on the underlying logger
        XCTAssertNil(logHandler.logArguments)
    }
}
