import Vapor
import JWT
import Foundation

public struct FQAuthSessionToken: Content, Authenticatable, JWTPayload {

  public let sub: SubjectClaim // user id
  public let exp: ExpirationClaim
  public let iat: IssuedAtClaim
  public let iss: IssuerClaim
  public let deviceName: String
  public let roles: [String]
  
  public static let expirationTime: TimeInterval = 60 * 60 * 2
  
  public func verify(using signer: JWTKit.JWTSigner) throws {
    try exp.verifyNotExpired()

    guard let _ = UUID(uuidString: sub.value) else {
      throw Errors.uuidNotParsableFromSubject
    }
  }

  public var userID: UUID? {
    UUID(uuidString: sub.value)
  }

  public init(userID: UUID,
              deviceName: String,
              roles: [String],
              expiration: ExpirationClaim,
              iat: IssuedAtClaim = IssuedAtClaim(value: Date()),
              iss: IssuerClaim) {
    self.sub = SubjectClaim(value: userID.uuidString)
    self.exp = expiration
    self.iat = iat
    self.iss = iss
    self.deviceName = deviceName
    self.roles = roles
  }

  public enum Errors: Error {
    case uuidNotParsableFromSubject
  }
}
