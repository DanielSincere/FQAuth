import Vapor

enum EnvVars: String, CaseIterable {

  /// generate with `swish generate-jwt-key`
  case authPrivateKey = "AUTH_PRIVATE_KEY"

  /// from https://developer.apple.com/account/resources/authkeys/list
  case appleDeveloperKey = "APPLE_DEVELOPER_KEY"
  case appleDeveloperKeyId = "APPLE_DEVELOPER_KEY_ID"

  /// App Store Connect Team ID
  case appleTeamId = "APPLE_TEAM_ID"

  /// App Store Connect App Bundle ID
  case appleAppId = "APPLE_APP_ID"

  /// generate with `swish generate-db-key`
  case dbSymmetricKey = "DB_SYMMETRIC_KEY"

  /// from your hosting provider
  case postgresUrl = "DATABASE_URL"
  case redisUrl = "REDIS_URL"

  func loadOrFatal() -> String {
    guard let string = Environment.get(self.rawValue) else {
      fatalError("\(self.rawValue) not set in environment")
    }

    return string
  }

  func loadOrThrow() throws -> String {
    guard let string = Environment.get(self.rawValue) else {
      throw EnvVarMissingError(name: self.rawValue)
    }

    return string
  }

  struct EnvVarMissingError: Error {
    let name: String
  }

  struct EnvVarsMissingError: Error {
    let names: [String]
  }

  static func ensureAllPresent() throws {
    let names: [String] = Self.allCases
      .compactMap { envVar in
        do {
          _ = try envVar.loadOrThrow()
          return nil
        } catch {
          return envVar.rawValue
        }
      }

    if names.isEmpty {
      return
    }

    throw EnvVarsMissingError(names: names)
  }
}
