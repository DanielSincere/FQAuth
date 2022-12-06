import Vapor
import JWT
import PostgresNIO

extension Application {

  func configure() throws {
    try self.configurePostgres()
    try self.configureMigrations()
    //    try self.configureRedis()
    try self.configureRoutes()

    try self.configureSigning()
    
    self.configureCommands()
    
    self.services.siwaClient.use { application in
      LiveSIWAClient(application: application)
    }
  }
}
