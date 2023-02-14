import Vapor
import JWTKit

protocol SIWAVerifier {
  func verify(_ string: String) -> EventLoopFuture<AppleIdentityToken>
}

protocol SIWAVerifierProvider {
  func `for`(_ request: Vapor.Request) -> SIWAVerifier
}
