import Vapor
import FluentPostgresDriver

extension Application {
  func configurePostgres() throws {
    self.databases.use(.postgres(configuration: try .for(self.environment)), as: .psql)
  }
}

extension PostgresConfiguration {
  static func `for`(_ environment: Environment) throws -> PostgresConfiguration {
    let urlString = try EnvVars.postgresUrl.load()
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
    
    switch environment {
    case .production:
      var tlsConfig = TLSConfiguration.makeClientConfiguration()
      tlsConfig.certificateVerification = .none
      config.tlsConfiguration = tlsConfig
      
    case .development:
      break
      
    case .testing:
      if nil != Environment.get("TEST_DATABASE_TLS") {
        var tlsConfig = TLSConfiguration.makeClientConfiguration()
        tlsConfig.certificateVerification = .none
        config.tlsConfiguration = tlsConfig
      }
      
    default:
      break
    }
    return config
  }
}
