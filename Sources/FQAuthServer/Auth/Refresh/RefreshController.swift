import Vapor

final class RefreshTokenController {

  func token(req: Request) throws -> EventLoopFuture<AuthResponse> {


    let refreshTokenRequestBody = try req.content.decode(RefreshTokenRequestBody.self)

    return RefreshTokenModel
      .findBy(token: refreshTokenRequestBody.refreshToken, db: req.db)
      .unwrap(or: Abort(.forbidden))
      .flatMap { refreshTokenModel in
        UserModel.find(refreshTokenModel.$user.id, on: req.db)
          .unwrap(or: Abort(.forbidden))
          .flatMap { userModel in

            refreshTokenModel.delete(force: true, on: req.db)
              .flatMap { _ in
                AuthHelper(req: req)
                  .login(userId: userModel.id!,
                         firstName: userModel.firstName,
                         lastName: userModel.lastName,
                         deviceName: refreshTokenRequestBody.newDeviceName)
              }
          }
      }
  }
}

extension RefreshTokenController: RouteCollection {

  func boot(routes: RoutesBuilder) throws {
    routes.post("token", use: token)
  }
}
