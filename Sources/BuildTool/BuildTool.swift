import ArgumentParser
import Foundation

@main
@available(macOS 14, *)
struct BuildTool: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        subcommands: [
            BuildAndTestLibrary.self,
            BuildExampleApp.self,
            GenerateMatrices.self,
            Lint.self,
        ]
    )
}

@available(macOS 14, *)
struct BuildAndTestLibrary: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Build and test the AblyChat library")

    @Option var platform: Platform
    @Option var swiftVersion: Int

    mutating func run() async throws {
        let destinationSpecifier = try await platform.resolve()
        let scheme = "AblyChat"

        try await XcodeRunner.runXcodebuild(action: nil, scheme: scheme, destination: destinationSpecifier, swiftVersion: swiftVersion)
        try await XcodeRunner.runXcodebuild(action: "test", scheme: scheme, destination: destinationSpecifier, swiftVersion: swiftVersion)
    }
}

@available(macOS 14, *)
struct BuildExampleApp: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Build the AblyChatExample example app")

    @Option var platform: Platform
    @Option var swiftVersion: Int

    mutating func run() async throws {
        let destinationSpecifier = try await platform.resolve()

        try await XcodeRunner.runXcodebuild(action: nil, scheme: "AblyChatExample", destination: destinationSpecifier, swiftVersion: swiftVersion)
    }
}

struct GenerateMatrices: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Generate a build matrix that can be used for specifying which GitHub jobs to run",
        discussion: """
        Outputs a key=value string which, when appended to $GITHUB_OUTPUT, sets the job’s `matrix` output to a JSON object which can be used for generating builds. This allows us to make sure that our various matrix jobs use consistent parameters.

        This object has the following structure:

        {
            withoutPlatform: { tooling: Tooling }[]
            withPlatform: { tooling: Tooling, platform: PlatformArgument }[]
        }

        where Tooling is

        {
            xcodeVersion: string
            swiftVersion: number
        }

        and PlatformArgument is a value that can be passed as the --platform argument of the build-and-test-library or build-example-app commands.
        """
    )

    mutating func run() throws {
        let tooling = [
            [
                "xcodeVersion": "15.3",
                "swiftVersion": 5,
            ],
            [
                "xcodeVersion": "16-beta",
                "swiftVersion": 6,
            ],
        ]

        let matrix: [String: Any] = [
            "withoutPlatform": [
                "tooling": tooling,
            ],
            "withPlatform": [
                "tooling": tooling,
                "platform": Platform.allCases.map(\.rawValue),
            ],
        ]

        // I’m assuming the JSONSerialization output has no newlines
        let keyValue = try "matrix=\(String(decoding: JSONSerialization.data(withJSONObject: matrix), as: UTF8.self))"
        fputs("\(keyValue)\n", stderr)
        print(keyValue)
    }
}

@available(macOS 14, *)
struct Lint: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Checks code formatting and quality.")

    enum Error: Swift.Error {
        case malformedSwiftVersionFile
        case malformedPackageManifestFile
        case mismatchedVersions(swiftVersionFileVersion: String, packageManifestFileVersion: String)
        case packageLockfilesHaveDifferentContents(paths: [String])
    }

    @Flag(name: .customLong("fix"), help: .init("Fixes linting errors where possible before linting"))
    var shouldFix = false

    mutating func run() async throws {
        if shouldFix {
            try await fix()
            try await lint()
        } else {
            try await lint()
        }
    }

    func lint() async throws {
        try await ProcessRunner.run(executableName: "mint", arguments: ["run", "swiftformat", "--lint", "."])
        try await ProcessRunner.run(executableName: "mint", arguments: ["run", "swiftlint"])
        try await ProcessRunner.run(executableName: "npm", arguments: ["run", "prettier:check"])
        try await checkSwiftVersionFile()
        try await comparePackageLockfiles()
    }

    func fix() async throws {
        try await ProcessRunner.run(executableName: "mint", arguments: ["run", "swiftformat", "."])
        try await ProcessRunner.run(executableName: "mint", arguments: ["run", "swiftlint", "--fix"])
        try await ProcessRunner.run(executableName: "npm", arguments: ["run", "prettier:fix"])
    }

    /// Checks that the Swift version specified by the `Package.swift`’s `"swift-tools-version"` matches that in the `.swift-version` file (which is used to tell SwiftFormat the minimum version of Swift supported by our code). Per [SwiftFormat#1496](https://github.com/nicklockwood/SwiftFormat/issues/1496) it’s currently our responsibility to make sure they’re kept in sync.///
    func checkSwiftVersionFile() async throws {
        async let swiftVersionFileContents = loadUTF8StringFromFile(at: ".swift-version")
        async let packageManifestFileContents = loadUTF8StringFromFile(at: "Package.swift")

        guard let swiftVersionFileMatch = try await /^(\d+\.\d+)\n$/.firstMatch(in: swiftVersionFileContents) else {
            throw Error.malformedSwiftVersionFile
        }

        let swiftVersionFileVersion = String(swiftVersionFileMatch.1)

        guard let packageManifestFileMatch = try await /^\/\/ swift-tools-version: (\d+\.\d+)\n/.firstMatch(in: packageManifestFileContents) else {
            throw Error.malformedPackageManifestFile
        }

        let packageManifestFileVersion = String(packageManifestFileMatch.1)

        if swiftVersionFileVersion != packageManifestFileVersion {
            throw Error.mismatchedVersions(
                swiftVersionFileVersion: swiftVersionFileVersion,
                packageManifestFileVersion: packageManifestFileVersion
            )
        }
    }

    /// Checks that the SPM-managed Package.resolved matches the Xcode-managed one. (I still don’t fully understand _why_ there are two files).
    func comparePackageLockfiles() async throws {
        let lockfilePaths = ["Package.resolved", "AblyChat.xcworkspace/xcshareddata/swiftpm/Package.resolved"]
        let lockfileContents = try await withThrowingTaskGroup(of: String.self) { group in
            for lockfilePath in lockfilePaths {
                group.addTask {
                    try await loadUTF8StringFromFile(at: lockfilePath)
                }
            }

            return try await group.reduce(into: []) { accum, fileContents in
                accum.append(fileContents)
            }
        }

        if Set(lockfileContents).count > 1 {
            throw Error.packageLockfilesHaveDifferentContents(paths: lockfilePaths)
        }
    }

    private func loadUTF8StringFromFile(at path: String) async throws -> String {
        let (data, _) = try await URLSession.shared.data(from: .init(filePath: path))
        return String(decoding: data, as: UTF8.self)
    }
}
