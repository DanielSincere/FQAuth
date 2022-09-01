import Vapor
import JWT

extension Application {

  func configure() throws {

    self.routes.get("healthy") { req in
      return "healthy"
    }
    self.routes.get("jwks") { req in
      JWKS.public
    }

    try self.routes.register(collection: SIWAController())

    try self.jwt.apple.jwks.get(using: self.client, on: self.client.eventLoop).wait()

  }
}

extension JWKS: Content { }
