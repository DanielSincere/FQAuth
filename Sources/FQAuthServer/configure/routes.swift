import Vapor
import JWT

extension Application {

  func routes() throws {
    self.get("healthy") { req in
      return "healthy"
    }
    
    self.get("jwks") { req in
      JWKS.public
    }

    try self.register(collection: SIWAController())
    try self.register(collection: RefreshTokenController())
  }
}

extension JWKS: Content { }
