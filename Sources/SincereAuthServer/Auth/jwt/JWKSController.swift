import Vapor
import JWT

final class JWKSController {

  func `public`(req: Request) -> JWKS {
    JWKS.public
  }
}

extension JWKSController: RouteCollection {
  func boot(routes: Vapor.RoutesBuilder) throws {
    routes.get("jwks", "public", use: `public`)
  }
}

extension JWKS: Content { }
