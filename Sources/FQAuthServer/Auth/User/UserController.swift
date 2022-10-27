import Vapor
import FQAuthMiddleware

final class UserController {
  
  func activeTokens(req: Request) throws -> EventLoopFuture<UserInfo> {
    guard let userID = req.parameters.get("userID", as: UUID.self) else {
      throw Abort(.badRequest)
    }
    
    let token = try req.auth.require(FQAuthSessionToken.self)
    
    guard token.userID == userID else {
      throw Abort(.forbidden)
    }
    
    return RefreshTokenModel
      .listBy(userID: userID, db: req.db)
      .mapEach { model in
        UserInfo.RefreshToken(expiresAt: model.expiresAt, deviceName: model.deviceName, createdAt: model.createdAt)
      }
      .map { list in
        UserInfo(refreshTokens: list)
      }
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
    routes.group(FQAuthSessionToken.authenticator(), FQAuthSessionToken.guardMiddleware()) {
      $0.group("user", ":userID") { userRoutes in
        userRoutes.get("activeTokens", use: activeTokens(req:))
      }
    }
  }
}
