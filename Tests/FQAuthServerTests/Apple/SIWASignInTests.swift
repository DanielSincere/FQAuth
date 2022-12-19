@testable import FQAuthServer
import XCTest
import Vapor
import JWTKit
import Foundation

final class SIWASignInTests: XCTestCase {
  
  var app: Application!
  
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
    
    let existingUser = try SIWASignUpRepo(application: app)
      .signUp(signUpParams).wait()
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
      
      let maybeUser = try UserModel.findByAppleUserId("002024.1951936c61fa47debb2b076e6896ccc1.1949",
                                                      db: app.db(.psql)).wait()
      let user = try XCTUnwrap(maybeUser)
      XCTAssertEqual(user.firstName, "Nimesh")
      XCTAssertEqual(user.lastName, "Patel")
      XCTAssertEqual(user.registrationMethod, .siwa)
      
      let refreshTokens = try RefreshTokenModel.listBy(userID: try user.requireID(),
                                                       db: app.db(.psql)).wait()
      XCTAssertEqual(refreshTokens.count, 2)
    }
  }
}
