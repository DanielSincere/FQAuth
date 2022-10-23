import Vapor

final class UserController {
  
  func activeTokens(req: Request) -> EventLoopFuture<UserInfo> {
    req.eventLoop.makeFailedFuture(Abort(.badRequest))
  }
  
  struct UserInfo: Content {
    let refreshTokens: [RefreshToken]
    
    struct RefreshToken: Codable {
      let expiresAt: Date
      let deviceName: String
      let createdAt: Date
    }
  }
}
 
extension UserController: RouteCollection {
  func boot(routes: Vapor.RoutesBuilder) throws {
    routes.group("user", ":userID") { userRoutes in
      userRoutes.get("activeTokens", use: activeTokens(req:))
    }
  }
}
