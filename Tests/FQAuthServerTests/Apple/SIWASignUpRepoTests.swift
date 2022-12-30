import XCTest
import Vapor
@testable import FQAuthServer
import FluentPostgresDriver

final class SIWASignUpRepoTests: XCTestCase {
  
  var app: Application!
  
  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
    
    try app.autoRevert().wait()
    try app.autoMigrate().wait()
  }
    
  override func tearDownWithError() throws {
    app.shutdown()
  }
  
  var db: Database {
    app.databases.database(.psql, logger: app.logger, on: app.eventLoopGroup.next())!
  }
  
  func testSignUp() throws {
    let repo = SIWASignUpRepo(logger: app.logger,
                              eventLoop: app.eventLoopGroup.next(),
                              database: db as! SQLDatabase)
    let userID = try repo.signUp(.init(email: "tomato@example.com",
                                       firstName: "First",
                                       lastName: "Last",
                                       deviceName: "device",
                                       method: .siwa(appleUserId: "AppleUserId",
                                                     appleRefreshToken: "AppleRefresh")
                                      )).wait()
    
    let siwa = try XCTUnwrap(SIWAModel.findBy(appleUserId: "AppleUserId", db: self.db).wait())
    let user = try XCTUnwrap(UserModel.find(userID, on: self.db).wait())
    
    XCTAssertEqual(user.firstName, "First")
    XCTAssertEqual(user.lastName, "Last")
    XCTAssertEqual(user.registrationMethod, .siwa)
    XCTAssertEqual(user.status, .active)
    XCAssertDateNowish(user.createdAt)
    XCAssertDateNowish(user.updatedAt)
    
    XCTAssertEqual(siwa.email, "tomato@example.com")
    XCAssertDateNowish(siwa.createdAt)
    XCAssertDateNowish(siwa.updatedAt)
    XCTAssertEqual(siwa.attemptedRefreshAt, nil)
    XCTAssertEqual(siwa.appleUserId, "AppleUserId")
    XCTAssertEqual(siwa.unsealedAppleRefreshToken(), "AppleRefresh")
  }
}





