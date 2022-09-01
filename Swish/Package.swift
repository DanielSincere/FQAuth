// swift-tools-version:5.6

import PackageDescription

let package = Package(
  name: "Scripts",
  platforms: [.macOS(.v12)],
  dependencies: [
    .package(url: "https://github.com/FullQueueDeveloper/Sh.git", from: "1.0.0"),
  ],
  targets: [
    .executableTarget(
      name: "Date",
      dependencies: ["Sh"]
    ),
  ]
)
