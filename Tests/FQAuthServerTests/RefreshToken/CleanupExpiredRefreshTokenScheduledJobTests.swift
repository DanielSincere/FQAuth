import Foundation
import Vapor
@testable import FQAuthServer
import XCTest
import FluentPostgresDriver

final class CleanupExpiredRefreshTokenScheduledJobTests: XCTestCase {

  var app: Application!
  var existingUserID: UserModel.IDValue!

  func testDeletesExpiredTokens() async throws {
    try RefreshTokenModel(userId: existingUserID,
                          deviceName: "iPhone",
                          expiresAt: Date(timeIntervalSinceNow: -6000))
      .save(on: app.db(.psql)).wait()

    let beforeCount = try await countRefreshTokens()
    XCTAssertEqual(beforeCount, 1)

    try await runJob()

    let afterCount = try await countRefreshTokens()
    XCTAssertEqual(afterCount, 0)
  }

  func testDoesntDeleteUnexpiredTokens() async throws {
    try RefreshTokenModel(userId: existingUserID,
                          deviceName: "iPhone")
      .save(on: app.db(.psql)).wait()

    let beforeCount = try await countRefreshTokens()
    XCTAssertEqual(beforeCount, 1)

    try await runJob()

    let afterCount = try await countRefreshTokens()
    XCTAssertEqual(afterCount, 1)
  }

  private func runJob() async throws {
    try await CleanupExpiredRefreshTokenScheduledJob
      .executeSQL(db: app.db(.psql) as! SQLDatabase,
                  logger: Logger(label: "test logger"))
  }

  private func countRefreshTokens() async throws -> Int {
    try await RefreshTokenModel.query(on: app.db(.psql)).count()
  }

  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
    try app.resetDatabase()

    self.existingUserID = try XCTUnwrap(SIWASignUpRepo(application: app)
      .createTestUser(appleUserId: "existingAppleID"))
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }
}
