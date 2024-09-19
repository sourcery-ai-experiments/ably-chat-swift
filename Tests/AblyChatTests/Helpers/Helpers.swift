import Ably
@testable import AblyChat
import Testing

/**
 Tests whether a given optional `Error` is an `ARTErrorInfo` in the chat error domain with a given code.
 */
func isChatError(_ maybeError: (any Error)?, withCode code: AblyChat.ErrorCode) -> Bool {
    guard let ablyError = maybeError as? ARTErrorInfo else {
        return false
    }

    return ablyError.domain == AblyChat.errorDomain as String
        && ablyError.code == code.rawValue
        && ablyError.statusCode == code.statusCode
}
