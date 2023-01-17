@testable import FQAuthServer
import XCTest
import Foundation
import Vapor
import JWTKit

final class SIWAServerNotificationRequestTests: XCTestCase {

  var app: Application!

  let appleUserId = "820417.faa325acbc78e1be1668ba852d492d8a.0219"

  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
    try app.resetDatabase()

    try SIWASignUpRepo(application: app).createTestUser(appleUserId: appleUserId)
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }

  func testConsentRevoked() throws {

    let notification = SIWAServerNotification(
      iss: IssuerClaim(value: "https://appleid.apple.com"),
      aud: AudienceClaim(stringLiteral: "com.fullqueuedeveloper.FQAuth"),
      iat: IssuedAtClaim(value: Date()),
      jti: IDClaim(value: "abede67890"),
      events: try .init(string: """
          {
            \"type\":\"consent-revoked\",
            \"sub\":\"\(appleUserId)\",
            \"event_time\":1670016125295
          }
          """))

    let jwt: String = try app.jwt.signers.sign(notification)
    let notifyBody = SIWAController.NotifyBody(payload: jwt)
    let notificationBodyJson = try JSONEncoder().encode(notifyBody)

    try app.test(.POST, "/api/siwa/notify",
                 headers: HTTPHeaders([("content-type", "application/json")]),
                 body: ByteBuffer(data: notificationBodyJson)) { response in

      XCTAssertEqual(response.status, .ok)

      let nextJobId = try XCTUnwrap(app.queues.queue.pop().wait())
      let nextJob = try app.queues.queue.get(nextJobId).wait()
      let payload: String = try JSONDecoder().decode(String.self, from: ByteBuffer(bytes: nextJob.payload))
      XCTAssertEqual(nextJob.jobName, "ConsentRevokedJob")
      XCTAssertEqual(payload, appleUserId)
    }
  }

  func testAccountDelete() throws {
    let notification = SIWAServerNotification(
      iss: IssuerClaim(value: "https://appleid.apple.com"),
      aud: AudienceClaim(stringLiteral: "com.fullqueuedeveloper.FQAuth"),
      iat: IssuedAtClaim(value: Date()),
      jti: IDClaim(value: "abede67890"),
      events: try .init(string: """
          {
            \"type\":\"account-delete\",
            \"sub\":\"\(appleUserId)\",
            \"event_time\":1670016125295
          }
          """))

    let jwt: String = try app.jwt.signers.sign(notification)
    let notifyBody = SIWAController.NotifyBody(payload: jwt)
    let notificationBodyJson = try JSONEncoder().encode(notifyBody)

    try app.test(.POST, "/api/siwa/notify",
                 headers: HTTPHeaders([("content-type", "application/json")]),
                 body: ByteBuffer(data: notificationBodyJson)) { response in

      XCTAssertEqual(response.status, .ok)

      let nextJobId = try XCTUnwrap(app.queues.queue.pop().wait())
      let nextJob = try app.queues.queue.get(nextJobId).wait()
      let payload: String = try JSONDecoder().decode(String.self, from: ByteBuffer(bytes: nextJob.payload))
      XCTAssertEqual(nextJob.jobName, "SIWAAccountDeletedJob")
      XCTAssertEqual(payload, appleUserId)
    }
  }

  func testEmailEnabled() throws {
    let notification = SIWAServerNotification(
      iss: IssuerClaim(value: "https://appleid.apple.com"),
      aud: AudienceClaim(stringLiteral: "com.fullqueuedeveloper.FQAuth"),
      iat: IssuedAtClaim(value: Date()),
      jti: IDClaim(value: "abede67890"),
      events: try .init(string: """
          {
            \"type\":\"email-enabled\",
            \"sub\":\"\(appleUserId)\",
            \"event_time\":1673016125295,
            \"email\": "new@example.nyc",
            \"is_private_email\": "true"
          }
          """))

    let jwt: String = try app.jwt.signers.sign(notification)
    let notifyBody = SIWAController.NotifyBody(payload: jwt)
    let notificationBodyJson = try JSONEncoder().encode(notifyBody)

    try app.test(.POST, "/api/siwa/notify",
                 headers: HTTPHeaders([("content-type", "application/json")]),
                 body: ByteBuffer(data: notificationBodyJson)) { response in
      
      XCTAssertEqual(response.status, .ok)
      
      let nextJobId = try XCTUnwrap(app.queues.queue.pop().wait())
      let nextJob = try app.queues.queue.get(nextJobId).wait()
      let payload: EmailEnabledJob.Payload = try JSONDecoder().decode(EmailEnabledJob.Payload.self, from: ByteBuffer(bytes: nextJob.payload))
      XCTAssertEqual(nextJob.jobName, "EmailEnabledJob")
      XCTAssertEqual(payload, .init(newEmail: "new@example.nyc",
                                    appleUserID: appleUserId))
    }
  }
}
