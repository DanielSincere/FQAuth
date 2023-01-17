import Foundation
@testable import FQAuthServer
import PostgresKit
import FluentPostgresDriver
import XCTest
import Vapor

final class ConsentRevokedJobTest: XCTestCase {

  var app: Application!
  var existingUserID: UserModel.IDValue!
  var existingUser: UserModel!
  var existingSIWAModel: SIWAModel!
  let existingAppleID: String = "002024.1951936c61fa47debb2b076e6896ccc1.1949"

  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()

    try app.resetDatabase()

    let signUpParams = SIWASignUpRepo.Params(email: "test@example.com",
                                             firstName: "First",
                                             lastName: "Last",
                                             deviceName: "iPhone",
                                             method: .siwa(appleUserId: existingAppleID,
                                                           appleRefreshToken: "AppleRefreshToken"))

    self.existingUserID = try SIWASignUpRepo(application: app)
      .signUp(signUpParams)
      .wait()

    self.existingSIWAModel = try SIWAModel
      .findBy(appleUserId: existingAppleID, db: app.db(.psql))
      .wait()
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }

  func testJobDeactivatesUser() throws {

    try ConsentRevokedJob.deactivateUser(with: existingAppleID,
                                         logger: Logger(label: String(describing: self)),
                                         db: app.db(.psql))
      .wait()

    let modifiedUser = try XCTUnwrap(UserModel
      .findByAppleUserId(existingAppleID, db: app.db(.psql))
      .wait())

    let modifiedSiwa = try XCTUnwrap(modifiedUser.siwa)

    XCTAssertEqual(modifiedSiwa.encryptedAppleRefreshToken, nil)
    XCTAssertEqual(modifiedUser.status, .deactivated)
  }
}
