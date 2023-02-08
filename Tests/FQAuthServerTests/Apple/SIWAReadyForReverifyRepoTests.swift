import Foundation
@testable import FQAuthServer
import XCTest
import Vapor
import PostgresKit

final class SIWAReadyForReverifyRepoTests: XCTestCase {

  var app: Application!
  var userID: UserModel.IDValue!
  var siwaModel: SIWAModel!

  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
    try app.resetDatabase()

    self.userID = try SIWASignUpRepo(application: app)
      .createTestUser(appleUserId: "002024.1951936c61fa47debb2b076e6896ccc1.1949")

    self.siwaModel = try XCTUnwrap(SIWAModel.findBy(userId: userID, db: app.db(.psql)).wait())
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }

  func testShouldNotAttemptRefreshWhenNewUser() async throws {
    let repo = SIWAReadyForReverifyRepo(application: self.app)
    let results = try await repo.fetch()

    XCTAssertEqual(results.count, 0)
  }

  func testShouldNotAttemptRefreshWhenNewUserIsJustUnderOneDayOld() async throws {
    siwaModel.createdAt = Date(timeIntervalSinceNow: -86400 + 60)
    try siwaModel.save(on: app.db(.psql)).wait()

    let repo = SIWAReadyForReverifyRepo(application: self.app)
    let results = try await repo.fetch()

    XCTAssertEqual(results.count, 0)
  }

  func testShouldAttemptRefreshWhenNewUserIsOverOneDayOld() async throws {
    siwaModel.createdAt = Date(timeIntervalSinceNow: -86400 - 60 )
    try siwaModel.save(on: app.db(.psql)).wait()

    let repo = SIWAReadyForReverifyRepo(application: self.app)
    let results = try await repo.fetch()

    XCTAssertEqual(results.count, 1)
    XCTAssertTrue(try XCTUnwrap(results.first).shouldAttemptRefresh())
  }

  func testShouldAttemptWhenSuccessAndAttemptedRefreshIsEmpty() async throws {
    siwaModel.attemptedRefreshAt = nil
    siwaModel.attemptedRefreshResult = .success
    try siwaModel.save(on: app.db(.psql)).wait()

    let repo = SIWAReadyForReverifyRepo(application: self.app)
    let results = try await repo.fetch()

    XCTAssertEqual(results.count, 1)
    XCTAssertTrue(try XCTUnwrap(results.first).shouldAttemptRefresh())
  }

  func testShouldAttemptWhenFailureAndAttemptedRefreshIsEmpty() async throws {
    siwaModel.attemptedRefreshAt = nil
    siwaModel.attemptedRefreshResult = .failure
    try siwaModel.save(on: app.db(.psql)).wait()


    let repo = SIWAReadyForReverifyRepo(application: self.app)
    let results = try await repo.fetch()

    XCTAssertEqual(results.count, 1)
    XCTAssertTrue(try XCTUnwrap(results.first).shouldAttemptRefresh())
  }

  func testShouldAttemptWhenFailureAndLatestRefreshWasOverADayAgo() async throws {
    siwaModel.attemptedRefreshAt = Date(timeIntervalSinceNow: -86400 - 60)
    siwaModel.attemptedRefreshResult = .failure
    try siwaModel.save(on: app.db(.psql)).wait()

    let repo = SIWAReadyForReverifyRepo(application: self.app)
    let results = try await repo.fetch()

    XCTAssertEqual(results.count, 1)
    XCTAssertTrue(try XCTUnwrap(results.first).shouldAttemptRefresh())
  }

  func testShouldAttemptWhenSuccessAndLatestRefreshWasOverADayAgo() async throws {
    siwaModel.attemptedRefreshAt = Date(timeIntervalSinceNow: -86400 - 60)
    siwaModel.attemptedRefreshResult = .success
    try siwaModel.save(on: app.db(.psql)).wait()

    let repo = SIWAReadyForReverifyRepo(application: self.app)
    let results = try await repo.fetch()

    XCTAssertEqual(results.count, 1)
    XCTAssertTrue(try XCTUnwrap(results.first).shouldAttemptRefresh())
  }

  func testShouldNotAttemptWhenSuccessAndLatestRefreshWasUnderDayAgo() async throws {
    siwaModel.attemptedRefreshAt = Date(timeIntervalSinceNow: -86400 + 60)
    siwaModel.attemptedRefreshResult = .success
    try siwaModel.save(on: app.db(.psql)).wait()

    let repo = SIWAReadyForReverifyRepo(application: self.app)
    let results = try await repo.fetch()

    XCTAssertEqual(results.count, 0)
  }

  func testShouldNotAttemptWhenFailureAndLatestRefreshWasUnderDayAgo() async throws {
    siwaModel.attemptedRefreshAt = Date(timeIntervalSinceNow: -86400 + 60)
    siwaModel.attemptedRefreshResult = .failure
    try siwaModel.save(on: app.db(.psql)).wait()

    let repo = SIWAReadyForReverifyRepo(application: self.app)
    let results = try await repo.fetch()

    XCTAssertEqual(results.count, 0)
  }
}
