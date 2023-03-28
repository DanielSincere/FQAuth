// swift-tools-version:5.7

import PackageDescription

let package = Package(
  name: "Scripts",
  platforms: [.macOS(.v12)],
  dependencies: [
    .package(url: "https://github.com/FullQueueDeveloper/Sh.git", from: "1.0.0"),
    .package(url: "https://github.com/FullQueueDeveloper/ShLocalPostgres.git", from: "0.1.0"),
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.2"),
  ],
  targets: [
    .executableTarget(
      name: "generate-jwt-key",
      dependencies: ["Sh"]
    ),
    .executableTarget(
      name: "generate-db-key",
      dependencies: ["Sh"]
    ),
    .executableTarget(
      name: "local-postgres",
      dependencies: [
        "ShLocalPostgres",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]
    ),
  ]
)
