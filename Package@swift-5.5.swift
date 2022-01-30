// swift-tools-version:5.5

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
            .upToNextMajor(from: "1.0.2")),
    ],
    targets: [
        .executableTarget(
            name: "XcCommand",
            dependencies: [
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"),
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
