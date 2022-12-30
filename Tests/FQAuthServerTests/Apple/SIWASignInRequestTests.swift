@testable import FQAuthServer
import XCTest
import Vapor
import JWTKit
import Foundation

final class SIWASignInRequestTests: XCTestCase {
  
  var app: Application!
  var existingUserID: UserModel.IDValue!
  var existingUser: UserModel!
  
  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
    
    try app.autoRevert().wait()
    try app.autoMigrate().wait()
    
    let signUpParams = SIWASignUpRepo.Params(email: "test@example.com",
                                             firstName: "First",
                                             lastName: "Last",
                                             deviceName: "iPhone",
                                             method: .siwa(appleUserId: "AppleUserId",
                                                           appleRefreshToken: "AppleRefreshToken"))
    
    self.existingUserID = try SIWASignUpRepo(application: app).signUp(signUpParams)
      .wait()
    self.existingUser = try UserModel.find(existingUserID, on: app.db(.psql))
      .wait()
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
      
      let maybeUser = try UserModel.findByAppleUserId("AppleUserId",
                                                      db: app.db(.psql)).wait()
      
      let user = try XCTUnwrap(maybeUser)
      XCTAssertEqual(existingUser.firstName, user.firstName)
      XCTAssertEqual(user.firstName, "First")
      XCTAssertEqual(user.lastName, "Last")
      XCTAssertEqual(user.registrationMethod, .siwa)
      
      let refreshTokens = try RefreshTokenModel.listBy(userID: try user.requireID(),
                                                       db: app.db(.psql)).wait()
      XCTAssertEqual(refreshTokens.count, 2)
    }
  }
}
