@testable import FQAuthServer
import XCTest
import Vapor
import JWTKit
import Foundation

final class SIWASignUpTests: XCTestCase {

  var app: Application!
  
  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
    
    try app.autoRevert().wait()
    try app.autoMigrate().wait()
    
    app.services.siwaVerifierProvider.use { application in
      var fake = FakeSIWAVerifier(eventLoop: application.eventLoopGroup.next())
      
      let tokenResponse = try! JSONDecoder().decode(AppleTokenResponse.self, from: ByteBuffer(string: AppleFixtures.successfulSiwaSignInBody))
      
      let stub = try! JWTSigners().unverified(tokenResponse.id_token,as: AppleIdentityToken.self)
      fake.verifyStub = stub
      return fake
    }
    
    app.services.siwaClient.use { application in
      var fake = FakeSIWAClient(eventLoop: application.eventLoopGroup.next())
      fake.generateRefreshTokenStub = AppleTokenResponse(access_token: "token",
                                                         expires_in: 3600,
                                                         id_token: "id_token",
                                                         refresh_token: "refresh_token",
                                                         token_type: "bearer")
      return fake
    }
  }
  
  override func tearDownWithError() throws {
    app.shutdown()
  }

  func testSignUp() throws {
    let requestBody = """
      {
        "appleIdentityToken": "FakeToken",
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
      
      let maybeUser = try UserModel.findByAppleUserId("002024.1951936c61fa47debb2b076e6896ccc1.1949",
                                                      db: app.db(.psql)).wait()
      let user = try XCTUnwrap(maybeUser)
      XCTAssertEqual(user.firstName, "Nimesh")
      XCTAssertEqual(user.lastName, "Patel")
      XCTAssertEqual(user.registrationMethod, .siwa)
      
      let maybeSiwa = try SIWAModel.findBy(appleUserId: "002024.1951936c61fa47debb2b076e6896ccc1.1949", db: app.db(.psql)).wait()
      let siwa = try XCTUnwrap(maybeSiwa)
      let email = try XCTUnwrap(siwa.email)
      XCTAssertTrue(email.starts(with: "fullqueue"))
      XCTAssertTrue(siwa.isActive)
      XCTAssertEqual(siwa.createdAt.timeIntervalSinceReferenceDate,
                     Date().timeIntervalSinceReferenceDate,
                     accuracy: 2)
      
      let refreshTokens = try RefreshTokenModel.listBy(userID: try user.requireID(),
                                                       db: app.db(.psql)).wait()
      XCTAssertEqual(refreshTokens.count, 1)
      
      let refreshToken = try XCTUnwrap(refreshTokens.first)
      XCTAssertEqual(refreshToken.deviceName, "iPhone")
      
      XCTAssertEqual(refreshToken.createdAt.timeIntervalSinceReferenceDate,
                     Date().timeIntervalSinceReferenceDate,
                     accuracy: 3)

      XCTAssertEqual(refreshToken.expiresAt.timeIntervalSinceReferenceDate,
                     Date().addingTimeInterval(AuthConstant.refreshTokenLifetime).timeIntervalSinceReferenceDate,
                     accuracy: 2)
    }
  }
}
