@testable import FQAuthServer
import XCTest
import Vapor

final class SIWAAuthorizeTests: XCTestCase {

  var app: Application!
  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()

  }
  
  override func tearDownWithError() throws {
    app.shutdown()
  }

  func testSignUp() throws {
    app.services.siwaClient.use { application in
      FakeSIWAClient(eventLoop: application.eventLoopGroup.next())
    }
  }
  
  struct FakeSIWAClient: SIWAClient {
    let eventLoop: EventLoop
    
    struct StubMissing: Error { }
    
    var validateRefreshTokenStub: AppleAuthTokenResult?
    func validateRefreshToken(token: String) -> NIOCore.EventLoopFuture<FQAuthServer.AppleAuthTokenResult> {
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
  }
}
