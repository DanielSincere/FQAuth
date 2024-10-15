import JWT
import Vapor
import SincereAuthMiddleware

extension SincereAuthSessionToken {
  init(userId: UUID, deviceName: String, roles: [String], now: Date = Date()) {

    self.init(userID: userId,
              deviceName: deviceName,
              roles: roles,
              expiration: .init(value: now.addingTimeInterval(AuthConstant.accessTokenLifetime)),
              iss: .init(value: EnvVars.selfIssuerId.loadOrFatal()))
  }
}
