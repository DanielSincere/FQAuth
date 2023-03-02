import Vapor
import JWT
import FQAuthMiddleware

extension Application {

  func configureRoutes() throws {
    self.get("healthy") { req in
      return "healthy"
    }

    let apiRoutes = self.grouped("api")
    try apiRoutes.register(collection: JWKSController())
    try apiRoutes.register(collection: SIWAController())
    try apiRoutes.register(collection: RefreshTokenController())
    try apiRoutes.register(collection: UserController())

    try self.register(collection: LoginController())

    try self.register(collection: AdminWebController())
  }
}
