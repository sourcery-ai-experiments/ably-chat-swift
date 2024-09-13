@testable import AblyChat
import XCTest

class InternalLoggerTests: XCTestCase {
    func test_protocolExtension_logMessage_defaultArguments_populatesFileIDAndLine() throws {
        let logger = MockInternalLogger()

        let expectedLine = #line + 1
        logger.log(message: "Here is a message", level: .info)

        let receivedArguments = try XCTUnwrap(logger.logArguments)

        XCTAssertEqual(receivedArguments.level, .info)
        XCTAssertEqual(receivedArguments.message, "Here is a message")
        XCTAssertEqual(receivedArguments.codeLocation, .init(fileID: #fileID, line: expectedLine))
    }
}
