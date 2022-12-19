import Vapor
import JWTKit

protocol SIWAVerifier {
  func `for`(_ request: Vapor.Request) -> SIWAVerifier
  func verify(_ string: String) -> EventLoopFuture<AppleIdentityToken>
}

final class LiveSIWAVerifier: SIWAVerifier {
  
  let apple: Request.JWT.Apple
  init(request: Request) {
    self.apple = request.jwt.apple
  }
  
  func verify(_ string: String) -> EventLoopFuture<AppleIdentityToken> {
    apple.verify(string)
  }
  
  func `for`(_ request: Vapor.Request) -> SIWAVerifier {
    LiveSIWAVerifier(request: request)
  }
}
