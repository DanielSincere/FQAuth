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

  func testShouldNotAttemptRefreshWhenNewUser() throws {
    var results = [SIWAModel]()
    let repo = SIWAReadyForReverifyRepo(application: self.app)
    try repo.fetch { results.append($0) }.wait()

    XCTAssertEqual(results.count, 0)
  }

  func testShouldNotAttemptRefreshWhenNewUserIsJustUnderOneDayOld() throws {
    siwaModel.createdAt = Date(timeIntervalSinceNow: -86400 + 60)
    try siwaModel.save(on: app.db(.psql)).wait()

    var results = [SIWAModel]()
    let repo = SIWAReadyForReverifyRepo(application: self.app)
    try repo.fetch { results.append($0) }.wait()

    XCTAssertEqual(results.count, 0)
  }

  func testShouldAttemptRefreshWhenNewUserIsOverOneDayOld() throws {
    siwaModel.createdAt = Date(timeIntervalSinceNow: -86400 - 60 )
    try siwaModel.save(on: app.db(.psql)).wait()

    var results = [SIWAModel]()
    let repo = SIWAReadyForReverifyRepo(application: self.app)
    try repo.fetch { results.append($0) }.wait()

    XCTAssertEqual(results.count, 1)
    XCTAssertTrue(try XCTUnwrap(results.first).shouldAttemptRefresh())
  }

  func testShouldAttemptWhenSuccessAndAttemptedRefreshIsEmpty() throws {
    siwaModel.attemptedRefreshAt = nil
    siwaModel.attemptedRefreshResult = .success
    try siwaModel.save(on: app.db(.psql)).wait()

    var results = [SIWAModel]()
    let repo = SIWAReadyForReverifyRepo(application: self.app)
    try repo.fetch { results.append($0) }.wait()

    XCTAssertEqual(results.count, 1)
    XCTAssertTrue(try XCTUnwrap(results.first).shouldAttemptRefresh())
  }

  func testShouldAttemptWhenFailureAndAttemptedRefreshIsEmpty() throws {
    siwaModel.attemptedRefreshAt = nil
    siwaModel.attemptedRefreshResult = .failure
    try siwaModel.save(on: app.db(.psql)).wait()

    var results = [SIWAModel]()
    let repo = SIWAReadyForReverifyRepo(application: self.app)
    try repo.fetch { results.append($0) }.wait()

    XCTAssertEqual(results.count, 1)
    XCTAssertTrue(try XCTUnwrap(results.first).shouldAttemptRefresh())
  }

  func testShouldAttemptWhenFailureAndLatestRefreshWasOverADayAgo() throws {
    siwaModel.attemptedRefreshAt = Date(timeIntervalSinceNow: -86400 - 60)
    siwaModel.attemptedRefreshResult = .failure
    try siwaModel.save(on: app.db(.psql)).wait()

    var results = [SIWAModel]()
    let repo = SIWAReadyForReverifyRepo(application: self.app)
    try repo.fetch { results.append($0) }.wait()

    XCTAssertEqual(results.count, 1)
    XCTAssertTrue(try XCTUnwrap(results.first).shouldAttemptRefresh())
  }

  func testShouldAttemptWhenSuccessAndLatestRefreshWasOverADayAgo() throws {
    siwaModel.attemptedRefreshAt = Date(timeIntervalSinceNow: -86400 - 60)
    siwaModel.attemptedRefreshResult = .success
    try siwaModel.save(on: app.db(.psql)).wait()

    var results = [SIWAModel]()
    let repo = SIWAReadyForReverifyRepo(application: self.app)
    try repo.fetch { results.append($0) }.wait()

    XCTAssertEqual(results.count, 1)
    XCTAssertTrue(try XCTUnwrap(results.first).shouldAttemptRefresh())
  }

  func testShouldNotAttemptWhenSuccessAndLatestRefreshWasUnderDayAgo() throws {
    siwaModel.attemptedRefreshAt = Date(timeIntervalSinceNow: -86400 + 60)
    siwaModel.attemptedRefreshResult = .success
    try siwaModel.save(on: app.db(.psql)).wait()

    var results = [SIWAModel]()
    let repo = SIWAReadyForReverifyRepo(application: self.app)
    try repo.fetch { results.append($0) }.wait()

    XCTAssertEqual(results.count, 0)
  }

  func testShouldNotAttemptWhenFailureAndLatestRefreshWasUnderDayAgo() throws {
    siwaModel.attemptedRefreshAt = Date(timeIntervalSinceNow: -86400 + 60)
    siwaModel.attemptedRefreshResult = .failure
    try siwaModel.save(on: app.db(.psql)).wait()

    var results = [SIWAModel]()
    let repo = SIWAReadyForReverifyRepo(application: self.app)
    try repo.fetch { results.append($0) }.wait()

    XCTAssertEqual(results.count, 0)
  }
}
