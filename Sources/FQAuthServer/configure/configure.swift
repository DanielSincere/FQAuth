import Vapor
import JWT
import PostgresNIO

extension Application {

  func configure() throws {
    try self.configurePostgres()
    try self.configureMigrations()
    try self.configureRedis()
    self.configureQueues()
    try self.configureRoutes()

    try self.configureSigning()
    
    self.configureCommands()
    
    self.configureServices()
  }
}
