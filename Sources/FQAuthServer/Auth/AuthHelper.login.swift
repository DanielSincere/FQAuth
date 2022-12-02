import Vapor

struct AuthHelper {
  let request: Request

  func login(userId: UUID, firstName: String?, lastName: String?, deviceName: String) -> EventLoopFuture<AuthResponse> {

    let refreshToken: String = [UInt8].random(count: 512 / 8).hex

    return RefreshTokenModel(userId: userId,
                             deviceName: deviceName,
                             token: refreshToken)
    .create(on: request.db)
    .flatMapThrowing { _ in
      let accessJWT = AuthJWT(userId: userId, deviceName: deviceName)

      let accessToken = try request.jwt.sign(accessJWT, kid: .authPrivateKey)

      return AuthResponse(user: .init(id: userId,
                                      firstName: firstName,
                                      lastName: lastName),
                          refreshToken: refreshToken,
                          accessToken: accessToken)
    }
  }
}
