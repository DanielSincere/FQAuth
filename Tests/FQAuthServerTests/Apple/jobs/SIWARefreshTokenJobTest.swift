import Foundation
@testable import FQAuthServer
import XCTest
import Vapor

final class SIWARefreshTokenJobTest: XCTestCase {

  var app: Application!
  var existingUserID: UserModel.IDValue!
  let existingAppleID: String = "002024.1951936c61fa47debb2b076e6896ccc1.1949"

  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
    try app.resetDatabase()

    self.existingUserID = try SIWASignUpRepo(application: app)
      .createTestUser(appleUserId: existingAppleID)
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }

  func testHitsAppleClientAndDoesSomething() async throws {

    let maybeModel = try await SIWAModel.findBy(appleUserId: existingAppleID,
              db: app.db(.psql)).get()
    let siwa = try XCTUnwrap(maybeModel)

    /*
     {
       "access_token": "beg510...67Or9",
       "token_type": "Bearer",
       "expires_in": 3600,
       "id_token": "eyJra...96sZg"
     }
     */

    let client = FakeSIWAClient(eventLoop: app.eventLoopGroup.next(), validateRefreshTokenStub: .token(AppleTokenRefreshResponse(access_token: "beg510...67Or9", expires_in: 3600, id_token: "eyJra...96sZg", , token_type: "Bearer")))

    try await RefreshTokenJob.refreshTokenWithApple(
      siwaID: try siwa.requireID(),
      logger: Logger(label: "test"),
      db: app.db(.psql), client: client)

    
  }
}
