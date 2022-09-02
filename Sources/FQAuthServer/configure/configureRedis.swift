import Vapor
import FluentPostgresDriver
import Redis

extension Application {
  func configureRedis() throws {

    let urlString = try EnvVars.redisUrl.loadOrThrow()
    guard let url = URL(string: urlString) else {
      struct NotAnURLError: Error {
        let string: String
      }
      throw NotAnURLError(string: urlString)
    }

    switch self.environment {
    case .production:
      let pool = RedisConfiguration.PoolOptions(connectionRetryTimeout: .seconds(1))
      try self.redis.configuration = .init(url: url, pool: pool)
    case .development, .testing:
      try self.redis.configuration = .init(url: url)
    default:
      break
    }
  }
}
