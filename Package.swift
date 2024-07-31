// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "AblyChat",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
        .tvOS(.v14),
    ],
    products: [
        .library(
            name: "AblyChat",
            targets: [
                "AblyChat",
            ]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/ably/ably-cocoa",
            from: "1.2.0"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.5.0"
        ),
    ],
    targets: [
        .target(
            name: "AblyChat",
            dependencies: [
                .product(
                    name: "Ably",
                    package: "ably-cocoa"
                ),
            ],
            swiftSettings: [
                // We build with strict concurrency checking enabled, because:
                //
                // 1. in theory it’s a useful language feature that reduces
                //    bugs
                // 2. it will be unavoidable if we migrate to Swift 6, so let’s
                //    future-proof ourselves
                //
                // This is the first time that I’ll have used strict
                // concurrency checking, so I don’t know what kind of impact it
                // might have; I’ve seen anecdotes that it can make developers’
                // lives tricky.
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
        .testTarget(
            name: "AblyChatTests",
            dependencies: [
                "AblyChat",
            ]
        ),
        .executableTarget(
            name: "BuildTool",
            dependencies: [
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                ),
            ],
            swiftSettings: [
                // See justification above.
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("BareSlashRegexLiterals"),
            ]
        ),
    ]
)
