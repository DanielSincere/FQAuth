import Foundation
import XCTVapor
import XCTest
@testable import FQAuthServer

final class RefreshTokenModelTests: XCTestCase {
  
  var app: Application!
  
  func testFindValidToken() throws {
    let user = UserModel(firstName: "First", lastName: "Success", registrationMethod: .siwa)
    try user.create(on: app.db(.psql)).wait()
    
    let refreshToken = RefreshTokenModel(userId: try user.requireID(), deviceName: "My iPhone X", token: "test-token")
    try refreshToken.create(on: app.db(.psql)).wait()
    
    
    let found = try XCTUnwrap(try RefreshTokenModel.findBy(token: "test-token", db: app.db(.psql)).wait())
    XCTAssertEqual(refreshToken.deviceName, found.deviceName)
    XCTAssertEqual(refreshToken.$user.id, found.$user.id)
    XCTAssertEqual(refreshToken.id, found.id)
  }
  
  override func setUpWithError() throws {
    let app = Application(.testing)
    try app.configure()
    try app.resetDatabase()
    self.app = app
  }
  
  override func tearDownWithError() throws {
    app.shutdown()
  }
}
