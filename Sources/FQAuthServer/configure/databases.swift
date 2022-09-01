import Vapor
import FluentPostgresDriver
import Redis

extension Application {
  func databases(_ app: Application) throws {

    switch app.environment {

    case .production:
      try app.redis.configuration = .init(url: URL(string: EnvVars.redisUrl.loadOrFatal())!,
                                          pool: .init(connectionRetryTimeout: .seconds(1)))

      var config = PostgresConfiguration(url: EnvVars.postgresUrl.loadOrFatal())!
      var tlsConfig = TLSConfiguration.makeClientConfiguration()
      tlsConfig.certificateVerification = .none
      config.tlsConfiguration = tlsConfig
      app.databases.use(.postgres(configuration: config), as: .psql)

    case .development, .testing:

      try app.redis.configuration = .init(url: URL(string: EnvVars.redisUrl.loadOrFatal())!)

      app.databases.use(.postgres(configuration: PostgresConfiguration(url: EnvVars.postgresUrl.loadOrFatal())!), as: .psql)

    default:
      break
    }
  }
}
