import XCTest
import Vapor
@testable import FQAuthServer

final class SIWAServerNotificationDecodingTests: XCTestCase {
  
  var app: Application!
  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
  }
  
  override func tearDownWithError() throws {
    app.shutdown()
  }
  
  
  func testDocumentationExample() throws {
    let json = """
        {
            "iss": "https://appleid.apple.com",
            "aud": "\(try EnvVars.appleAppId.loadOrThrow())",
            "iat": 1508184845,
            "jti": "abede...67890",
            "events": {
                "type": "consent-revoked",
                "sub": "820417.faa325acbc78e1be1668ba852d492d8a.0219",
                "event_time": 1508184845
            }
        }
        """
    
    let notification = try app.jwt.signers.verify(json, as: SIWAServerNotification.self)
//    let notification = SIWAServerNotification //try JSONDecoder().decode(SIWAServerNotification, from: json)
//    XCTAssertEqual(notification.events.single?., <#T##expression2: Equatable##Equatable#>)
  }
  
  func testFixture() throws {

    
    let body = try JSONDecoder().decode(SIWAController.NotifyBody.self, from: AppleFixtures.siwaNotificationBody.data(using: .utf8)!)
    let notification = try app.jwt.signers.unverified(body.payload, as: SIWAServerNotification.self) // TODO: use verify
    XCTAssertEqual(notification.iss, "https://appleid.apple.com")
    XCTAssertNoThrow(try notification.aud.verifyIntendedAudience(includes: try EnvVars.appleAppId.loadOrThrow()))

    
    
  }
  
}
