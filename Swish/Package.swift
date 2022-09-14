// swift-tools-version:5.6

import PackageDescription

let package = Package(
  name: "Scripts",
  platforms: [.macOS(.v11)],
  dependencies: [
    .package(url: "https://github.com/FullQueueDeveloper/Sh.git", from: "1.0.0"),
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
  ]
)
