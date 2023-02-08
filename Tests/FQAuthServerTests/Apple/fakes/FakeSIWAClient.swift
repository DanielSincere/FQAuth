import Foundation
import Vapor
@testable import FQAuthServer

struct FakeSIWAClient: SIWAClient {
  
  let eventLoop: EventLoop
  
  struct StubMissing: Error { }
  
  var validateRefreshTokenStub: AppleAuthTokenResult?
  func validateRefreshToken(token: String) -> NIOCore.EventLoopFuture<FQAuthServer.AppleAuthTokenRefreshResult> {
    if let stub = validateRefreshTokenStub {
      return eventLoop.makeSucceededFuture(stub)
    } else {
      return eventLoop.makeFailedFuture(StubMissing())
    }
  }
  
  var generateRefreshTokenStub: AppleTokenResponse?
  func generateRefreshToken(code: String) -> NIOCore.EventLoopFuture<FQAuthServer.AppleTokenResponse> {
    if let stub = generateRefreshTokenStub {
      return eventLoop.makeSucceededFuture(stub)
    } else {
      return eventLoop.makeFailedFuture(StubMissing())
    }
  }
  
  func `for`(_ request: Vapor.Request) -> FQAuthServer.SIWAClient {
    self
  }
}
