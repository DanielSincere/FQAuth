import Vapor

enum EnvVars: String, CaseIterable {

  case authPrivateKey = "AUTH_PRIVATE_KEY"

  case appleServicesKey = "APPLE_SERVICES_KEY"
  case appleServicesKeyId = "APPLE_SERVICES_KEY_ID"
  case appleTeamId = "APPLE_TEAM_ID"
  case appleAppId = "APPLE_APP_ID"

  case dbSymmetricKey = "DB_SYMMETRIC_KEY"

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
