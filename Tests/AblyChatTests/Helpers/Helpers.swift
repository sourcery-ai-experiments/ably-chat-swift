import Ably
@testable import AblyChat
import XCTest

/**
 Asserts that a given optional `Error` is an `ARTErrorInfo` in the chat error domain with a given code.
 */
func assertIsChatError(_ maybeError: (any Error)?, withCode code: AblyChat.ErrorCode, file: StaticString = #filePath, line: UInt = #line) throws {
    let error = try XCTUnwrap(maybeError, "Expected an error", file: file, line: line)
    let ablyError = try XCTUnwrap(error as? ARTErrorInfo, "Expected an ARTErrorInfo", file: file, line: line)

    XCTAssertEqual(ablyError.domain, AblyChat.errorDomain as String, file: file, line: line)
    XCTAssertEqual(ablyError.code, code.rawValue, file: file, line: line)
    XCTAssertEqual(ablyError.statusCode, code.statusCode, file: file, line: line)
}
