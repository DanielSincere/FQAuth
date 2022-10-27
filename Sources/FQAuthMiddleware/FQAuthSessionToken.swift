import Vapor
import JWT
import Foundation

public struct FQAuthSessionToken: Content, Authenticatable, JWTPayload {
  
  public let userID: UUID
  public var expiration: ExpirationClaim
  
  public static let expirationTime: TimeInterval = 60 * 60 * 2
  
  public func verify(using signer: JWTKit.JWTSigner) throws {
    try expiration.verifyNotExpired()
  }
}
