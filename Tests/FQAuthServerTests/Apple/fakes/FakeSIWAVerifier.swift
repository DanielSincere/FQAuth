import Foundation
import Vapor
@testable import FQAuthServer
import JWT

struct FakeSIWAVerifier: SIWAVerifier, SIWAVerifierProvider {
  let eventLoop: EventLoop
  
  struct StubMissing: Error { }
  
  var verifyStub: AppleIdentityToken?
  func verify(_ string: String) -> NIOCore.EventLoopFuture<JWTKit.AppleIdentityToken> {
    guard let stub = verifyStub else {
      return eventLoop.makeFailedFuture(StubMissing())
    }
    
    return eventLoop.makeSucceededFuture(stub)
  }
  
  func `for`(_ request: Vapor.Request) -> FQAuthServer.SIWAVerifier {
    FakeSIWAVerifier(eventLoop: request.eventLoop, verifyStub: verifyStub)
  }
}
