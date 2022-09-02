import Vapor
import FluentPostgresDriver
import Redis

extension Application {
  func redis() throws {

    switch self.environment {

    case .production:
      try self.redis.configuration = .init(url: URL(string: EnvVars.redisUrl.loadOrFatal())!,
                                          pool: .init(connectionRetryTimeout: .seconds(1)))

    case .development, .testing:

      try self.redis.configuration = .init(url: URL(string: EnvVars.redisUrl.loadOrFatal())!)

    default:
      fatalError("unrecognized environment")
    }
  }
}
