# Contributing

## Requirements

- The Xcode version [mentioned in the README](./README.md#requirements)
- [Mint](https://github.com/yonaskolb/Mint) package manager
- Node.js (any recent version should be fine)

## Setup

1. `mint bootstrap` — this will take quite a long time (~5 minutes on my machine) the first time you run it
2. `npm install`

## Running the tests

Either:

- `swift test`, or
- open `AblyChat.xcworkspace` in Xcode and test the `AblyChat` scheme

## Linting

To check formatting and code quality, run `swift run BuildTool lint`. Run with `--fix` to first automatically fix things where possible.

## Development guidelines

- The aim of the [example app](README.md#example-app) is that it demonstrate all of the core functionality of the SDK. So if you add a new feature, try to add something to the example app to demonstrate this feature.
- We should aim to make it easy for consumers of the SDK to be able to mock out the SDK in the tests for their own code. A couple of things that will aid with this:
  - Describe the SDK’s functionality via protocols (when doing so would still be sufficiently idiomatic to Swift).
  - When defining a `struct` that is emitted by the public API of the library, make sure to define a memberwise initializer so that users can create one to be emitted by their mocks. (In Xcode, you can do this by clicking at the start of the type declaration and doing Editor → Refactor → Generate Memberwise Initializer.)

## Building for Swift 6

At the time of writing (August 2024), the latest version of Swift to ship with a release version of Xcode is Swift 5.10. However, in the next few months Apple will launch Swift 6, which refines the strict concurrency checking introduced in Swift 5.10. Specifically, my understanding is that it introduces features that make Swift 5.10’s strict concurrency checking more developer-friendly. I think that some of these features can be switched on in Swift 5.10, but I’m not sure if all of them can. So, Swift 6 releases we might decide that we want to switch to using Swift 6 for our SDK. So, in CI, in addition to Swift 5 language mode, we also try building the SDK in Swift 6 language mode using the latest Xcode 16 beta.

And, actually more importantly, we want to be sure that the SDK can be integrated into a user’s application that uses Swift 6. So, in CI, in addition to Swift 5 language mode, we also try building the example app in Swift 6 language mode using the aforementioned Xcode beta.

(If any of the above turns out to cause a lot of problems due to the quality of the beta software, we can reconsider this.)

### Multiple `Package.swift` files

We have a separate manifest file, `Package@swift-6.swift`, which a Swift compiler supporting Swift 6 will use instead of `Package.swift` (see [documentation of this SPM feature](https://github.com/swiftlang/swift-package-manager/blob/74f06f8a7fd6b4c729e474dee34db66319d90759/Documentation/Usage.md#version-specific-manifest-selection)). This file only exists because if you try to use `.enableUpcomingFeature` for a feature that is enabled by default in Swift 6, you’ll get an error `error: upcoming feature 'BareSlashRegexLiterals' is already enabled as of Swift version 6`. (I don’t know if there’s a better way of handling this.)

So, we need to make sure we keep `Package.swift` and `Package@swift-6.swift` in sync manually.
