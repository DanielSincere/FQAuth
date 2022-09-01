import JWT
import Vapor

struct AuthJWT: JWTPayload {

  let sub: SubjectClaim // user id
  let exp: ExpirationClaim
  let iat: IssuedAtClaim
  let iss: IssuerClaim
  let deviceName: String
}

extension AuthJWT {
  func verify(using signer: JWTSigner) throws {
    try exp.verifyNotExpired()

    guard iss.value == AuthConstant.selfIssuer else {
      throw JWTError.claimVerificationFailure(name: "iss", reason: "mismatch")
    }
  }

  init(userId: UUID, deviceName: String, now: Date = Date()) {
    self.sub = .init(value: userId.uuidString)
    self.iat = .init(value: now)
    self.exp = .init(value: now.addingTimeInterval(AuthConstant.accessTokenLifetime))
    self.deviceName = deviceName
    self.iss = .init(value: AuthConstant.selfIssuer)
  }
}
