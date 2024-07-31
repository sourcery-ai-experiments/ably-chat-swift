// swift-tools-version: 6.0

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
            ]
        ),
    ]
)