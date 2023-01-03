@testable import FQAuthServer
import XCTest
import Foundation
import Vapor

final class SIWAServerNotificationRequestTests: XCTestCase {

  var app: Application!

  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
    try app.resetDatabase()
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }

  func testConsentRevoked() throws {
    let payloadJson = #"""
        {
            "iss": "https://appleid.apple.com",
            "aud": "com.mytest.app",
            "iat": 1508184845,
            "jti": "abede67890",
            "events": "{\"type\":\"consent-revoked\",\"sub\":\"820417.faa325acbc78e1be1668ba852d492d8a.0219\",\"event_time\":1670016125295}"
        }
        """#
    let notifyBody = SIWAController.NotifyBody(payload: payloadJson)
    let notificationBodyJson = try JSONEncoder().encode(notifyBody)

    try app.test(.POST, "/api/siwa/notify",
                 headers: HTTPHeaders([("content-type", "application/json")]),
                 body: ByteBuffer(data: notificationBodyJson)) { response in
      XCTAssertEqual(response.status, .ok)
    }
  }
}
