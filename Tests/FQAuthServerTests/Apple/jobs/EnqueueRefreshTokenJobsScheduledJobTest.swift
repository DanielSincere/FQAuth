import Foundation
@testable import FQAuthServer
import PostgresKit
import FluentPostgresDriver
import XCTest
import Vapor

final class EnqueueRefreshTokenJobsScheduledJobTest: XCTestCase {


  var app: Application!

  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
    try app.resetDatabase()
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }

  func testDoesNothingWhenTheresNoAccounts() throws {
    try EnqueueRefreshTokenJobsScheduledJob.enqueueRefreshTokenJobsForAccountsThatNeedRefreshing(
      logger: Logger(label: "test logger"),
      db: app.db(.psql))
    .wait()

    let nextJob = try app.queues.queue.pop().wait()
    XCTAssertNil(nextJob)
  }

  func testDoesNothingWhenTheresNoAccountsThatNeedRefreshing() throws {


    let userID = try SIWASignUpRepo(application: app)
      .createTestUser(appleUserId: "002024.1951936c61fa47debb2b076e6896ccc1.1949")
    try EnqueueRefreshTokenJobsScheduledJob.enqueueRefreshTokenJobsForAccountsThatNeedRefreshing(
      logger: Logger(label: "test logger"),
      db: app.db(.psql))
    .wait()

    let nextJob = try app.queues.queue.pop().wait()
    XCTAssertNil(nextJob)
  }

  func testEnqueusJobsForAccountsThatNeedRefreshing() throws {

    let userID = try SIWASignUpRepo(application: app)
      .createTestUser(appleUserId: "002024.1951936c61fa47debb2b076e6896ccc1.1949")

    let siwa1 = try SIWAModel.findBy(appleUserId: "002024.1951936c61fa47debb2b076e6896ccc1.1949", db: app.db(.psql)).wait()


    let userID2 = try SIWASignUpRepo(application: app)
      .createTestUser(appleUserId: "002024.1951936c61fa47debb2b076e6896ccc1.1999")

    try EnqueueRefreshTokenJobsScheduledJob.enqueueRefreshTokenJobsForAccountsThatNeedRefreshing(
      logger: Logger(label: "test logger"),
      db: app.db(.psql))
    .wait()

    let nextJob = try XCTUnwrap(app.queues.queue.pop().wait())

  }
}
