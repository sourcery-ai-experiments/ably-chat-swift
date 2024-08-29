import Ably

/**
 The error domain used for the ``Ably.ARTErrorInfo`` error instances thrown by the Ably Chat SDK.

 See ``ErrorCode`` for the possible ``ARTErrorInfo.code`` values.
 */
public let errorDomain = "AblyChatErrorDomain"

/**
 The error codes for errors in the ``errorDomain`` error domain.
 */
public enum ErrorCode: Int {
    /// ``Rooms.get(roomID:options:)`` was called with a different set of room options than was used on a previous call. You must first release the existing room instance using ``Rooms.release(roomID:)``.
    ///
    /// TODO this code is a guess, revisit in https://github.com/ably-labs/ably-chat-swift/issues/32
    case inconsistentRoomOptions = 1

    /// The ``ARTErrorInfo.statusCode`` that should be returned for this error.
    internal var statusCode: Int {
        // TODO: These are currently a guess, revisit in https://github.com/ably-labs/ably-chat-swift/issues/32
        switch self {
        case .inconsistentRoomOptions:
            400
        }
    }
}

/**
 The errors thrown by the Chat SDK.

 This type exists in addition to ``ErrorCode`` to allow us to attach metadata which can be incorporated into the error’s `localizedDescription`.
 */
internal enum ChatError {
    case inconsistentRoomOptions(requested: RoomOptions, existing: RoomOptions)

    /// The ``ARTErrorInfo.code`` that should be returned for this error.
    internal var code: ErrorCode {
        switch self {
        case .inconsistentRoomOptions:
            .inconsistentRoomOptions
        }
    }

    /// The ``ARTErrorInfo.localizedDescription`` that should be returned for this error.
    internal var localizedDescription: String {
        switch self {
        case let .inconsistentRoomOptions(requested, existing):
            "Rooms.get(roomID:options:) was called with a different set of room options than was used on a previous call. You must first release the existing room instance using Rooms.release(roomID:). Requested options: \(requested), existing options: \(existing)"
        }
    }
}

internal extension ARTErrorInfo {
    convenience init(chatError: ChatError) {
        var userInfo: [String: Any] = [:]
        // TODO: copied and pasted from implementation of -[ARTErrorInfo createWithCode:status:message:requestId:] because there’s no way to pass domain; revisit in https://github.com/ably-labs/ably-chat-swift/issues/32. Also the ARTErrorInfoStatusCode variable in ably-cocoa is not public.
        userInfo["ARTErrorInfoStatusCode"] = chatError.code.statusCode
        userInfo[NSLocalizedDescriptionKey] = chatError.localizedDescription

        self.init(
            domain: errorDomain,
            code: chatError.code.rawValue,
            userInfo: userInfo
        )
    }
}
