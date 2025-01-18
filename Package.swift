// swift-tools-version: 5.10.1

import PackageDescription

let package = Package(
  name: "skbd",
  platforms: [
    .macOS(.v14)
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0")
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
      name: "skbdlib"
    ),
    .testTarget(
      name: "skbdlibTests",
      dependencies: ["skbdlib"]
    ),
  ]
)
