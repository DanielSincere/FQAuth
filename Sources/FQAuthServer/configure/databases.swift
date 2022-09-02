import Vapor
import FluentPostgresDriver
import Redis

extension Application {
  func databases() throws {

    switch self.environment {

    case .production:
      try self.redis.configuration = .init(url: URL(string: EnvVars.redisUrl.loadOrFatal())!,
                                          pool: .init(connectionRetryTimeout: .seconds(1)))

      var config = PostgresConfiguration(url: EnvVars.postgresUrl.loadOrFatal())!
      var tlsConfig = TLSConfiguration.makeClientConfiguration()
      tlsConfig.certificateVerification = .none
      config.tlsConfiguration = tlsConfig
      self.databases.use(.postgres(configuration: config), as: .psql)

    case .development, .testing:

      try self.redis.configuration = .init(url: URL(string: EnvVars.redisUrl.loadOrFatal())!)

      self.databases.use(.postgres(configuration: PostgresConfiguration(url: EnvVars.postgresUrl.loadOrFatal())!), as: .psql)

    default:
      break
    }
  }
}
