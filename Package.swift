// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "focus-n-break",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "focus-n-break",
            targets: ["focus-n-break"]
        )
    ],
    targets: [
        .executableTarget(
            name: "focus-n-break"
        ),
        .testTarget(
            name: "focus-n-breakTests",
            dependencies: ["focus-n-break"]
        )
    ]
)
