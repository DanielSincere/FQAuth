@testable import FQAuthServer
import XCTest
import Vapor
import JWTKit
import Foundation

final class SIWASignInRequestTests: XCTestCase {
  
  var app: Application!
  var existingUserID: UserModel.IDValue!
  var existingUser: UserModel!
  let existingAppleID: String = "002024.1951936c61fa47debb2b076e6896ccc1.1949"
  
  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
    
    try app.autoRevert().wait()
    try app.autoMigrate().wait()
    
    let signUpParams = SIWASignUpRepo.Params(email: "test@example.com",
                                             firstName: "First",
                                             lastName: "Last",
                                             deviceName: "iPhone",
                                             method: .siwa(appleUserId: existingAppleID,
                                                           appleRefreshToken: "AppleRefreshToken"))
    
    self.existingUserID = try SIWASignUpRepo(application: app).signUp(signUpParams)
      .wait()
    self.existingUser = try UserModel.find(existingUserID, on: app.db(.psql))
      .wait()

    app.services.siwaVerifierProvider.use { application in
      var fake = FakeSIWAVerifier(eventLoop: application.eventLoopGroup.next())

      let tokenResponse = try! JSONDecoder().decode(AppleTokenResponse.self, from: ByteBuffer(string: AppleFixtures.successfulSiwaSignInBody))

      let stub = try! JWTSigners().unverified(tokenResponse.id_token,as: AppleIdentityToken.self)
      fake.verifyStub = stub
      return fake
    }

    app.services.siwaClient.use { application in
      var fake = FakeSIWAClient(eventLoop: application.eventLoopGroup.next())
      fake.generateRefreshTokenStub = AppleTokenResponse(access_token: "access_token",
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
  
  func testSignIn() throws {
    let requestBody = """
      {
        "appleIdentityToken": "FakeToken",
        "authorizationCode": "abcde",
        "deviceName": "iPhone",
      }
    """
    
    try app.test(.POST, "/api/siwa/authorize",
                 headers: HTTPHeaders([("Content-Type", "application/json")]),
                 body: ByteBuffer(string: requestBody)) { response in
      XCTAssertEqual(response.status, .ok)
      
      let maybeUser = try UserModel.findByAppleUserId(existingAppleID,
                                                      db: app.db(.psql)).wait()
      
      let user = try XCTUnwrap(maybeUser)
      XCTAssertEqual(existingUser.firstName, user.firstName)
      XCTAssertEqual(user.firstName, "First")
      XCTAssertEqual(user.lastName, "Last")
      XCTAssertEqual(user.registrationMethod, .siwa)
      
      let refreshTokens = try RefreshTokenModel.listBy(userID: try user.requireID(),
                                                       db: app.db(.psql)).wait()
      XCTAssertEqual(refreshTokens.count, 1)
    }
  }
}
