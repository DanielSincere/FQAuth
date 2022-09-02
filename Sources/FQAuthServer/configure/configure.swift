import Vapor
import JWT

extension Application {

  func configure() throws {
    try self.postgres()
    try self.migrations()
    try self.redis()
    try self.routes()

    try self.jwt.apple.jwks.get(using: self.client, on: self.client.eventLoop).wait()

  }
}
