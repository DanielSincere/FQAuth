@testable import FQAuthServer
import XCTest
import Foundation
import Vapor
import JWTKit

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

    _ = try SIWASignUpRepo(application: app).signUp(.init(
      email: "email@example.com",
      firstName: "First",
      lastName: "Last",
      deviceName: "TomatoDevice",
      method: .siwa(
        appleUserId: "820417.faa325acbc78e1be1668ba852d492d8a.0219",
        appleRefreshToken: "fakeToken"))
    ).wait()

    let _ = try SIWAModel.findBy(appleUserId: "820417.faa325acbc78e1be1668ba852d492d8a.0219", db: app.db(.psql)).wait()!

    let notification = SIWAServerNotification(
      iss: IssuerClaim(value: "https://appleid.apple.com"),
      aud: AudienceClaim(stringLiteral: "com.fullqueuedeveloper.FQAuth"),
      iat: IssuedAtClaim(value: Date()),
      jti: IDClaim(value: "abede67890"),
      events: try .init(string: #"{"type":"consent-revoked","sub":"820417.faa325acbc78e1be1668ba852d492d8a.0219","event_time":1670016125295}"#))

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
      XCTAssertEqual(payload, "820417.faa325acbc78e1be1668ba852d492d8a.0219")
    }
  }
}
