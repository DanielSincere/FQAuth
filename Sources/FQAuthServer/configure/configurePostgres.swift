import Vapor
import FluentPostgresDriver
import Redis

extension Application {
  func configurePostgres() throws {

    let urlString = try EnvVars.postgresUrl.loadOrThrow()
    guard let url = URL(string: urlString) else {
      struct NotAnURLError: Error {
        let string: String
      }
      throw NotAnURLError(string: urlString)
    }

    guard var config = PostgresConfiguration(url: url) else {
      struct PostgresConfigurationError: Error { }
      throw PostgresConfigurationError()
    }
    
    if nil != Environment.get("TEST_DATABASE_TLS") {
    
      
    }

    switch self.environment {
    case .production:
      var tlsConfig = TLSConfiguration.makeClientConfiguration()
      tlsConfig.certificateVerification = .none
      config.tlsConfiguration = tlsConfig
    case .development: break
    case .testing:
      if nil != Environment.get("TEST_DATABASE_TLS") {
        var tlsConfig = TLSConfiguration.makeClientConfiguration()
        tlsConfig.certificateVerification = .none
        config.tlsConfiguration = tlsConfig
      }
    default: break
    }
        
    self.databases.use(.postgres(configuration: config), as: .psql)
  }
}
