import Foundation
import XCTVapor
import XCTest
@testable import FQAuthServer

final class RefreshTokenControllerTests: XCTestCase {

  var app: Application!

  func testSuccessfulRefresh() throws {

    let user = UserModel(firstName: "First", lastName: "Success", registrationMethod: .siwa)
    _ = try user.create(on: app.db(.psql)).wait()

    let refreshToken = RefreshTokenModel(userId: try user.requireID(), deviceName: "My iPhone", token: "test-token")
    _ = try refreshToken.create(on: app.db(.psql)).wait()

    let requestBody = RefreshTokenRequestBody(refreshToken: "test-token", newDeviceName: "My iPhone")

    try app.test(.POST, "/api/token") { req in
      try req.content.encode(requestBody)
    } afterResponse: { response in
      let decodedResponseBody = try response.content.decode(AuthResponse.self)
      XCTAssertEqual(decodedResponseBody.user.firstName, "First")
      XCTAssertEqual(decodedResponseBody.user.lastName, "Success")
      XCTAssertEqual(response.status, .ok)
    }
  }

  func testRefreshTokenIsMissing() throws {
    let requestBody = RefreshTokenRequestBody(refreshToken: "missing-token",
                                              newDeviceName: "My iPhone")

    try app.test(.POST, "/api/token") { req in
      try req.content.encode(requestBody)
    } afterResponse: { response in
      XCTAssertEqual(response.status, .forbidden)
    }
  }

  func testRefreshTokenIsExpired() throws {

    let user = UserModel(firstName: "First", lastName: "Expired", registrationMethod: .siwa)

    _ = try user.create(on: app.db(.psql)).wait()

    let refreshToken = RefreshTokenModel(
      userId: try user.requireID(),
      deviceName: "My iPhone",
      token: "test-token",
      createdAt: Date(timeIntervalSince1970: 5),
      expiresAt: Date(timeIntervalSince1970: 20))

    _ = try refreshToken.create(on: app.db(.psql)).wait()

    let requestBody = RefreshTokenRequestBody(refreshToken: "test-token", newDeviceName: "My iPhone 3G")

    try app.test(.POST, "/api/token") { req in
      try req.content.encode(requestBody)
    } afterResponse: { response in
      XCTAssertEqual(response.status, .forbidden)
    }
  }

  override func setUpWithError() throws {
    let app = Application(.testing)
    try app.configure()
    try app.autoRevert().wait()
    try app.autoMigrate().wait()
    self.app = app
  }

  override func tearDownWithError() throws {
    try app.autoRevert().wait()
    app.shutdown()
  }
}
