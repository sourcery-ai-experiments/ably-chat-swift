# Ably Chat SDK for Swift

This is the repository for the Swift version of the Ably Chat SDK. We aim to build the same functionality that’s available in the [JavaScript SDK](https://github.com/ably/ably-chat-js).

> [!IMPORTANT]
> This SDK is currently in the early stages of development and is not ready to be used.

## Supported Platforms

- macOS 11 and above
- iOS 14 and above
- tvOS 14 and above

## Requirements

Xcode 16 (i.e. a compiler that supports Swift 6) or later.

## Installation

The SDK is distributed as a Swift package and can hence be installed using Xcode or by adding it as a dependency in your package’s `Package.swift`. We’ll add detailed instructions when we release the first version of the SDK.

## Example app

This repository contains an example app, written using SwiftUI, which demonstrates how to use the SDK. The code for this app is in the [`Example` directory](Example).

In order to allow the app to use modern SwiftUI features, it supports the following OS versions:

- macOS 14 and above
- iOS 17 and above
- tvOS 17 and above

To run the app, open the `AblyChat.xcworkspace` workspace in Xcode and run the `AblyChatExample` target. If you wish to run it on an iOS or tvOS device, you’ll need to set up code signing.

## Contributing

For information on how to contribute to this repository, please see the [contributing guidelines](CONTRIBUTING.md).
