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
    targets: [
        .target(
            name: "Xc",
            dependencies: []),
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)
