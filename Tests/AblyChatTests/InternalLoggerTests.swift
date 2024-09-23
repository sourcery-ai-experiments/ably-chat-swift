@testable import AblyChat
import Testing

struct InternalLoggerTests {
    @Test
    func protocolExtension_logMessage_defaultArguments_populatesFileIDAndLine() throws {
        let logger = MockInternalLogger()

        let expectedLine = #line + 1
        logger.log(message: "Here is a message", level: .info)

        let receivedArguments = try #require(logger.logArguments)

        #expect(receivedArguments.level == .info)
        #expect(receivedArguments.message == "Here is a message")
        #expect(receivedArguments.codeLocation == .init(fileID: #fileID, line: expectedLine))
    }
}
