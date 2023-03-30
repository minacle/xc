// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "Xc",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(
            name: "xc",
            targets: ["XcCommand"]),
        .library(
            name: "XcKit",
            type: .static,
            targets: ["XcKit"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            .upToNextMajor(from: "1.2.2")),
        .package(
            url: "https://github.com/apple/swift-atomics",
            .upToNextMajor(from: "1.0.3")),
    ],
    targets: [
        .executableTarget(
            name: "XcCommand",
            dependencies: [
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"),
                .product(
                    name: "Atomics",
                    package: "swift-atomics"),
                .target(name: "XcKit"),
            ]),
        .target(name: "XcKit"),
        .testTarget(
            name: "XcKitTests",
            dependencies: ["XcKit"]),
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)
