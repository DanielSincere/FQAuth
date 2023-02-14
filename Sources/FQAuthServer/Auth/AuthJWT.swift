import JWT
import Vapor
import FQAuthMiddleware

extension FQAuthSessionToken {
  init(userId: UUID, deviceName: String, now: Date = Date()) {

    self.init(userID: userId,
              deviceName: deviceName,
              expiration: .init(value: now.addingTimeInterval(AuthConstant.accessTokenLifetime)),
              iss: .init(value: AuthConstant.selfIssuer))
  }
}
