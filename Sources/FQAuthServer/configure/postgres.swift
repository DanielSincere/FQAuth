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

      let config = PostgresConfiguration(url: EnvVars.postgresUrl.loadOrFatal())!
      self.databases.use(.postgres(configuration: config), as: .psql)

    default:
      fatalError("unrecognized environment")
    }
  }
}
