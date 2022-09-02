import Vapor
import FluentPostgresDriver
import Redis

extension Application {
  func postgres() throws {

    switch self.environment {

    case .production:

      var config = PostgresConfiguration(url: EnvVars.postgresUrl.loadOrFatal())!
      var tlsConfig = TLSConfiguration.makeClientConfiguration()
      tlsConfig.certificateVerification = .none
      config.tlsConfiguration = tlsConfig
      self.databases.use(.postgres(configuration: config), as: .psql)

    case .development, .testing:

      self.databases.use(.postgres(configuration: PostgresConfiguration(url: EnvVars.postgresUrl.loadOrFatal())!), as: .psql)

    default:
      fatalError("unrecognized environment")
    }
  }
}
