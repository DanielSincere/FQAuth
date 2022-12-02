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
                do {
                  return AuthHelper(request: req)
                    .login(userId: try userModel.requireID(),
                           firstName: userModel.firstName,
                           lastName: userModel.lastName,
                           deviceName: refreshTokenRequestBody.newDeviceName)
                } catch {
                  return req.eventLoop.makeFailedFuture(Abort(.internalServerError))
                }
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
