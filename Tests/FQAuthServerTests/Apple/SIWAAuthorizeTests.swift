@testable import FQAuthServer
import XCTest
import Vapor
import JWTKit
import Foundation

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
      var fake = FakeSIWAClient(eventLoop: application.eventLoopGroup.next())
      fake.generateRefreshTokenStub = AppleTokenResponse(access_token: "token", expires_in: 3600, id_token: "id_token", refresh_token: "refresh_token", token_type: "type")
      return fake
    }
    app.services.siwaVerifier.use { application in
      var fake = FakeSIWAVerifier(eventLoop: application.eventLoopGroup.next())
      fake.verifyStub = try! JSONDecoder().decode(AppleIdentityToken.self, from: ByteBuffer(string: AppleFixtures.successfulSiwaSignInBody))
      return fake
    }

    let requestBody = """
      {
        "appleIdentityToken": "1234",
        "authorizationCode": "abcde",
        "deviceName": "iPhone",
        "firstName": "Nimesh",
        "lastName": "Patel"
      }
    """
    
    try app.test(.POST, "/api/siwa/authorize",
                 headers: HTTPHeaders([("Content-Type", "application/json")]),
                 body: ByteBuffer(string: requestBody)) { response in
      XCTAssertEqual(response.status, .ok)
    }
  }
  
  struct FakeSIWAVerifier: SIWAVerifier {
    let eventLoop: EventLoop
    
    struct StubMissing: Error { }
    
    var verifyStub: AppleIdentityToken?
    func verify(_ string: String) -> NIOCore.EventLoopFuture<JWTKit.AppleIdentityToken> {
      guard let stub = verifyStub else {
        return eventLoop.makeFailedFuture(StubMissing())
      }
      
      return eventLoop.makeSucceededFuture(stub)
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
