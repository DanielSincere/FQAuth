// swift-tools-version:5.7

import PackageDescription

let package = Package(
  name: "FQAuth",
  platforms: [
      .macOS(.v11),
  ],
  products: [
    .executable(name: "FQAuthServer", targets: ["FQAuthServer"]),
    .library(name: "FQAuthMiddleware", targets: ["FQAuthMiddleware"]),
  ],
  dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.65.1"),
    .package(url: "https://github.com/vapor/jwt.git", from: "4.2.1"),

    .package(url: "https://github.com/vapor/fluent.git", from: "4.3.1"),
    .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.1.3"),
    .package(url: "https://github.com/vapor/postgres-kit.git", from: "2.3.0"),

    .package(url: "https://github.com/vapor/redis.git", from: "4.1.3"),
    .package(url: "https://github.com/vapor/queues-redis-driver.git", from: "1.0.0"),
    .package(url: "https://github.com/FullQueueDeveloper/Sh.git", from: "1.0.2"),

  ],
  targets: [
    .executableTarget(name: "FQAuthServer", dependencies: [
      .product(name: "Vapor", package: "vapor"),
      .product(name: "JWT", package: "jwt"),

      .product(name: "PostgresKit", package: "postgres-kit"),
      .product(name: "Fluent", package: "fluent"),
      .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),

      .product(name: "Redis", package: "redis"),
      .product(name: "QueuesRedisDriver", package: "queues-redis-driver"),
      
      .target(name: "FQAuthMiddleware"),
      
      "Sh",
    ],
    swiftSettings: [
        .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
    ]),
    .target(name: "FQAuthMiddleware", dependencies: [
      .product(name: "Vapor", package: "vapor"),
      .product(name: "JWT", package: "jwt"),
    ]),
    .testTarget(name: "FQAuthServerTests", dependencies: [
      .product(name: "XCTVapor", package: "vapor"),
      "FQAuthServer",
    ]),
    .testTarget(name: "FQAuthMiddlewareTests", dependencies: [
      .product(name: "XCTVapor", package: "vapor"),
      "FQAuthMiddleware",
    ]),
  ]
)
