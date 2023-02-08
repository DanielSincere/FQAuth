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

  func testHitsAppleClientAndOnSuccessUpdatesLastRefreshedTimestamp() async throws {

    let maybeModel = try await SIWAModel.findBy(appleUserId: existingAppleID,
                                                db: app.db(.psql)).get()
    let siwa = try XCTUnwrap(maybeModel)

    let client = FakeSIWAClient(eventLoop: app.eventLoopGroup.next(),
                                validateRefreshTokenStub: .decoded(
                                  AppleTokenRefreshResponse(
                                    access_token: "beg510...67Or9",
                                    expires_in: 3600,
                                    id_token: "eyJra...96sZg",
                                    token_type: "Bearer")))

    try await RefreshTokenJob.refreshTokenWithApple(
      siwaID: try siwa.requireID(),
      logger: Logger(label: "test"),
      db: app.db(.psql),
      client: client,
      signers: app.jwt.signers
    )

    let maybeReloadedModel = try await SIWAModel.findBy(
      appleUserId: existingAppleID,
      db: app.db(.psql))
      .get()

    let reloadedSiwa = try XCTUnwrap(maybeReloadedModel)
    let attemptedRefreshAt = try XCTUnwrap(reloadedSiwa.attemptedRefreshAt)
    XCTAssertNearlyNow(attemptedRefreshAt)
    XCTAssertEqual(reloadedSiwa.attemptedRefreshResult, .success)
  }
}
