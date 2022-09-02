import Vapor
import JWT
import PostgresNIO

extension Application {

  func configure() throws {
    try self.configurePostgres()
    try self.configureMigrations()
    //    try self.configureRedis()
    try self.configureRoutes()

    try self.jwt.apple.jwks.get(using: self.client, on: self.client.eventLoop).wait()

    self.configureCommands()
  }
}



