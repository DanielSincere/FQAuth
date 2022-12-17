@testable import FQAuthServer
import XCTest
import Vapor
import JWTKit
import Foundation

final class SIWAAuthorizeTests: XCTestCase {

  var app: Application!
  override func setUpWithError() throws {
    self.app = Application(.testing)


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
    try app.configure()
  }
  
  override func tearDownWithError() throws {
    app.shutdown()
  }

  func testSignUp() throws {
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
}
