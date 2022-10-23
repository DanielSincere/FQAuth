import Vapor
import JWT

extension Application {

  func configureRoutes() throws {
    self.get("healthy") { req in
      return "healthy"
    }

    let apiRoutes = self.grouped("api")
    try apiRoutes.register(collection: JWKSController())
    try apiRoutes.register(collection: SIWAController())
    try apiRoutes.register(collection: RefreshTokenController())
  }
}
