// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Xc",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(
            name: "xc",
            targets: ["Xc"]),
        .library(
            name: "XcKit",
            type: .static,
            targets: ["XcKit"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            .upToNextMinor(from: "0.3.2")),
    ],
    targets: [
        .target(
            name: "Xc",
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
