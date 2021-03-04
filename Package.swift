// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Xc",
    platforms: [
        .macOS(.v10_10),
    ],
    products: [
        .executable(
            name: "xc",
            targets: ["Xc"]),
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
            ]),
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)
