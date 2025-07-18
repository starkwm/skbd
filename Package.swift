// swift-tools-version: 5.10.1

import PackageDescription

let package = Package(
  name: "skbd",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .executable(name: "skbd", targets: ["Skbd"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0")
  ],
  targets: [
    .executableTarget(
      name: "Skbd",
      dependencies: [
        "SkbdLib",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ],
      exclude: ["Version.swift.tmpl"]
    ),
    .target(
      name: "SkbdLib"
    ),
    .testTarget(
      name: "SkbdLibTests",
      dependencies: ["SkbdLib"],
      resources: [
        .copy("Resources")
      ]
    ),
  ]
)
