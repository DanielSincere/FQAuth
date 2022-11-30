import JWT
import Foundation

extension SIWAClient {
  struct ClientSecret: JWTPayload {
    let iss: IssuerClaim
    let iat: IssuedAtClaim
    let exp: ExpirationClaim
    let aud: AudienceClaim
    let sub: SubjectClaim

    init(clientId: String, teamId: String) {
      iss = .init(value: teamId)
      iat = .init(value: Date())
      exp = .init(value: Date(timeIntervalSinceNow: .oneDay))
      aud = .init(value: "https://appleid.apple.com")
      sub = .init(value: clientId)
    }

    /*
     "iss": "DEF123GHIJ",
     "iat": 1437179036,
     "exp": 1493298100,
     "aud": "https://appleid.apple.com",
     "sub": "com.mytest.app"
     */

    func verify(using signer: JWTSigner) throws {
      try self.exp.verifyNotExpired()
    }
  }
}
