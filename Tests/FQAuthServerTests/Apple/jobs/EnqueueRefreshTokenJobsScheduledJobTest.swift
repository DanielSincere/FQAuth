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

  func testDoesNothingWhenTheresNoAccounts() async throws {
    try await EnqueueRefreshTokenJobsScheduledJob.enqueueRefreshTokenJobsForAccountsThatNeedRefreshing(
      logger: Logger(label: "test logger"),
      db: app.db(.psql),
      queue: app.queues.queue)


    let nextJob = try app.queues.queue.pop().wait()
    XCTAssertNil(nextJob)
  }

  func testDoesNothingWhenTheresNoAccountsThatNeedRefreshing() async throws {


    let userID = try SIWASignUpRepo(application: app)
      .createTestUser(appleUserId: "002024.1951936c61fa47debb2b076e6896ccc1.1949")
    try await EnqueueRefreshTokenJobsScheduledJob.enqueueRefreshTokenJobsForAccountsThatNeedRefreshing(
      logger: Logger(label: "test logger"),
      db: app.db(.psql),
      queue: app.queues.queue)


    let nextJob = try app.queues.queue.pop().wait()
    XCTAssertNil(nextJob)
  }

  func testEnqueusJobsForAccountsThatNeedRefreshing() async throws {

    let userID = try SIWASignUpRepo(application: app)
      .createTestUser(appleUserId: "002024.1951936c61fa47debb2b076e6896ccc1.1949")

    let siwa1 = try XCTUnwrap(SIWAModel.findBy(appleUserId: "002024.1951936c61fa47debb2b076e6896ccc1.1949", db: app.db(.psql)).wait())
    siwa1.attemptedRefreshResult = .failure
    try siwa1.save(on: app.db(.psql)).wait()


    let userID2 = try SIWASignUpRepo(application: app)
      .createTestUser(appleUserId: "002024.1951936c61fa47debb2b076e6896ccc1.1999")

    let siwa2 = try XCTUnwrap(SIWAModel.findBy(appleUserId: "002024.1951936c61fa47debb2b076e6896ccc1.1999", db: app.db(.psql)).wait())

    siwa2.attemptedRefreshResult = .success
    try siwa2.save(on: app.db(.psql)).wait()

    try await EnqueueRefreshTokenJobsScheduledJob.enqueueRefreshTokenJobsForAccountsThatNeedRefreshing(
      logger: Logger(label: "test logger"),
      db: app.db(.psql), queue: app.queues.queue)

    let jobId1 = try XCTUnwrap(app.queues.queue.pop().wait())
    let job1 = try app.queues.queue.get(jobId1).wait()
    let payload1: SIWAModel.IDValue = try JSONDecoder().decode(SIWAModel.IDValue.self, from: ByteBuffer(bytes: job1.payload))

    let jobId2 = try XCTUnwrap(app.queues.queue.pop().wait())
    let job2 = try app.queues.queue.get(jobId2).wait()
    let payload2: SIWAModel.IDValue = try JSONDecoder().decode(SIWAModel.IDValue.self, from: ByteBuffer(bytes: job2.payload))

    XCTAssertEqual([payload1, payload2],
                   [try siwa1.requireID(), try siwa2.requireID()])

  }
}
