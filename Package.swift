// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "skbd",
    platforms: [
        .macOS(.v14),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.2"),
        .package(url: "https://github.com/starkwm/alicia", from: "2.0.4"),
    ],
    targets: [
        .executableTarget(
            name: "skbd",
            dependencies: [
                "skbdlib",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            exclude: ["version.swift.tmpl"]
        ),
        .target(
            name: "skbdlib",
            dependencies: [
                .product(name: "Alicia", package: "alicia"),
            ]
        ),
        .testTarget(
            name: "skbdlibTests",
            dependencies: ["skbdlib"]
        ),
    ]
)
