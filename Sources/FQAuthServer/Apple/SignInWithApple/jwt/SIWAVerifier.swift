import Vapor
import JWTKit

protocol SIWAVerifier {
  func verify(_ string: String) -> EventLoopFuture<AppleIdentityToken>
}

protocol SIWAVerifierProvider {
  func `for`(_ request: Vapor.Request) -> SIWAVerifier
}

struct LiveSIWAVerifierProvider: SIWAVerifierProvider {
  func `for`(_ request: Vapor.Request) -> SIWAVerifier {
    LiveSIWAVerifier(request: request)
  }
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
