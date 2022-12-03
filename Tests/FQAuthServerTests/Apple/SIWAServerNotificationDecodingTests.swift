import XCTest
import Vapor
@testable import FQAuthServer

final class SIWAServerNotificationDecodingTests: XCTestCase {
    
  func testDocumentationExample() throws {
    // The example in the documentation does not match JSON posted to my server from Apple. The example has been adjusted
    
    let json = #"""
        {
            "iss": "https://appleid.apple.com",
            "aud": "com.mytest.app",
            "iat": 1508184845,
            "jti": "abede67890",
            "events": "{\"type\":\"consent-revoked\",\"sub\":\"820417.faa325acbc78e1be1668ba852d492d8a.0219\",\"event_time\":1670016125295}"
        }
        """#
    
    let notification = try JSONDecoder().decode(SIWAServerNotification.self, from: json.data(using: .utf8)!)
    XCTAssertNoThrow(try notification.aud.verifyIntendedAudience(includes: "com.mytest.app"))
    switch notification.events.wrapped {
    case .emailEnabled(_):
      XCTFail()
    case .emailDisabled(_):
      XCTFail()
    case .consentRevoked(let revoked):
      XCTAssertEqual(revoked.sub.value, "820417.faa325acbc78e1be1668ba852d492d8a.0219")
    case .accountDelete(_):
      XCTFail()
    }
  }
  
  func testFixture() throws {
    let app: Application = Application(.testing)
    try app.useAppleJWKS()
    
    defer {
      app.shutdown()
    }
    
    let body = try JSONDecoder().decode(SIWAController.NotifyBody.self, from: AppleFixtures.siwaNotificationBody.data(using: .utf8)!)
    let notification = try app.jwt.signers.verify(body.payload, as: SIWAServerNotification.self) // TODO: use verify
    
    XCTAssertEqual(notification.iss, "https://appleid.apple.com")
    XCTAssertNoThrow(try notification.aud.verifyIntendedAudience(includes: try EnvVars.appleAppId.loadOrThrow()))
    
    switch notification.events.wrapped {
    case .emailEnabled(_):
      XCTFail()
    case .emailDisabled(_):
      XCTFail()
    case .consentRevoked(let revoked):
      XCTAssertEqual(revoked.sub.value, "002024.1951936c61fa47debb2b076e6896ccc1.1949")
    case .accountDelete(_):
      XCTFail()
    }
  }
}
