import Foundation

@available(macOS 14, *)
enum XcodeRunner {
    static func runXcodebuild(action: String?, scheme: String, destination: DestinationSpecifier, swiftVersion: Int) async throws {
        var arguments: [String] = []

        if let action {
            arguments.append(action)
        }

        arguments.append(contentsOf: ["-scheme", scheme])
        arguments.append(contentsOf: ["-destination", destination.xcodebuildArgument])

        arguments.append(contentsOf: [
            "SWIFT_TREAT_WARNINGS_AS_ERRORS=YES",
            "SWIFT_VERSION=\(swiftVersion)",
        ])

        try await ProcessRunner.run(executableName: "xcodebuild", arguments: arguments)
    }
}
