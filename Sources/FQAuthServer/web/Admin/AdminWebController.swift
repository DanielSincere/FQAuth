import Vapor
import FQAuthMiddleware

final class AdminWebController: RouteCollection {

  func boot(routes: RoutesBuilder) throws {
    routes
      .grouped(FQAuthMiddleware())
      .group("admin") { admin in
        admin.get("list-users", use: self.listUsers(req:))
      }
  }
}
