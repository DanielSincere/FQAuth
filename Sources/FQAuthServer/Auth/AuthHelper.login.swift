import Vapor
import FQAuthMiddleware

struct AuthHelper {
  let request: Request

  func login(userId: UUID, firstName: String?, lastName: String?, deviceName: String, roles: [String]) -> EventLoopFuture<AuthResponse> {

    let refreshToken: String = [UInt8].random(count: 512 / 8).hex

    return RefreshTokenModel(userId: userId,
                             deviceName: deviceName,
                             token: refreshToken)
    .create(on: request.db)
    .flatMapThrowing { _ in
      let accessJWT = FQAuthSessionToken(userId: userId, deviceName: deviceName, roles: roles)

      let accessToken = try request.jwt.sign(accessJWT, kid: .authPrivateKey)

      return AuthResponse(user: .init(id: userId,
                                      firstName: firstName,
                                      lastName: lastName),
                          refreshToken: refreshToken,
                          accessToken: accessToken)
    }
  }
}
