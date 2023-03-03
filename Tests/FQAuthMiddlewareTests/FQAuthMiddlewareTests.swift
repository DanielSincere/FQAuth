import XCTest
import XCTVapor
import JWTKit
@testable import FQAuthMiddleware

final class FQAuthMiddlewareTests: XCTestCase {

  let privateKey = Data(base64Encoded: "LS0tLS1CRUdJTiBFQyBQQVJBTUVURVJTLS0tLS0KQmdVcmdRUUFJdz09Ci0tLS0tRU5EIEVDIFBBUkFNRVRFUlMtLS0tLQotLS0tLUJFR0lOIEVDIFBSSVZBVEUgS0VZLS0tLS0KTUlIY0FnRUJCRUlCTnZBWXJLYk9CR29KSE1kKzBUNjdlUWdWWXdhVXlVUDIxdDlrdURFa1lQLzI0NndVMEwyYwpqSmFNdUI3dHZvSXZkWHZFZnNHdkRpZyswbFM1OXRtUW5HdWdCd1lGSzRFRUFDT2hnWWtEZ1lZQUJBQ1d4d0xBCkRsVFk5alZvNXYvVmNCZkpIZzZjUXdWUHlvZXcwWkxtMWVvY01PUm9FZFZucEZVZ20xVWZSVkdFRXZrbHRpV0cKOU5mZFVoL25QajNRWWx5V3VBRGdlS0NBMDBZVHhZNzNKd1RUTUlvczlmRXFOblh6TjBJUXhWVUFmYjFpKzd2SApvVURJRTlXNk1zbG9mQ3F3ZVFmeXJxa0c5VXU3VWtJNWgyS1M4RmU2VFE9PQotLS0tLUVORCBFQyBQUklWQVRFIEtFWS0tLS0tCg==")!

  var userID: UUID = UUID(uuidString: "1CB5E4AD-C9DC-4635-BC27-0AE1DA9637BD")!
  var authorizedToken: String!
  var app: Application!

  override func setUpWithError() throws {
    app = Application(.testing)

    app.jwt.signers.use(.es512(key: try ECDSAKey.private(pem: privateKey)),
                        kid: .authPrivateKey,
                        isDefault: true)

    app.routes.group(FQAuthMiddleware()) { secure in
      secure.get("hello") { req -> String in
        let token = req.fqSessionToken!
        return token.userID?.uuidString ?? "not a uuid"
      }
    }

    app.routes.group(FQAuthMiddleware(requiredRole: "admin")) { secure in
      secure.get("admin-only") { req -> String in
        let token = req.fqSessionToken!
        return token.userID?.uuidString ?? "not a uuid"
      }
    }

    let token = FQAuthSessionToken(userID: userID,
                                   deviceName: "Xample",
                                   roles: [],
                                   expiration: ExpirationClaim(value: Date(timeIntervalSinceNow: 600)),
                                   iss: IssuerClaim("com.example")
    )
    authorizedToken = try app.jwt.signers.sign(token, kid: .authPrivateKey)
  }

  override func tearDownWithError() throws {
    app.shutdown()
  }

  func testAuthorizedTokenIsValid() throws {
    let decoded = try app.jwt.signers.verify(authorizedToken, as: FQAuthSessionToken.self)
    XCTAssertEqual(decoded.userID, userID)
  }

  func testEmptyHeader() throws {
    try app.test(.GET, "hello") { response in
      XCTAssertEqual(response.status, .unauthorized)
      let error = try response.content.decode(VaporError.self)
      XCTAssertEqual(error.reason, #"Unauthorized"#)
    }
  }

  func testUnauthorizedToken() throws {

    let unauthorizedToken = "eyJhbGciOiJFUzUxMiIsInR5cCI6IkpXVCJ9.eyJ1c2VySUQiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMiwiZXhwIjoxNTE2MjY5MDIyfQ.AQ2k8FRDnt4dwwrvxtxGOJ-ThEbmC5q2G_KY-cOHZp_fN9Y9NTLpImLqEkCiXDt-jekz4ynuHn-Co53bV1GJfbeAAW3i6frDK8sQr2vrT2MI88swAi8JWHjKaH54hUJHKa67tNDzZtduOO1jquSB0975xWEg4LJmBSP92xp5P8fra38G"

    let headers = HTTPHeaders([("Authorization", "Bearer \(unauthorizedToken)")])
    try app.test(.GET, "hello", headers: headers) { response in
      XCTAssertEqual(response.status, .unauthorized)
      let error = try response.content.decode(VaporError.self)
      XCTAssertEqual(error.reason, #"signature verification failed"#)
    }
  }

  struct VaporError: Content, Codable, Equatable {
    let error: Bool
    let reason: String
  }

  func testAuthorized() throws {
    let headers = HTTPHeaders([("Authorization", "Bearer \(authorizedToken!)")])
    try app.test(.GET, "hello", headers: headers) { response in
      XCTAssertEqual(response.status, .ok)
      XCTAssertEqual(String(buffer: response.body), #"1CB5E4AD-C9DC-4635-BC27-0AE1DA9637BD"#)
    }
  }

  func testRejectsUsersWithoutRequiredRole() throws {
    let headers = HTTPHeaders([("Authorization", "Bearer \(authorizedToken!)")])
    try app.test(.GET, "admin-only", headers: headers) { response in
      XCTAssertEqual(response.status, .unauthorized)
      let error = try response.content.decode(VaporError.self)
      XCTAssertEqual(error.reason, #"Unauthorized"#)
    }
  }

  func testAcceptsUsersWithRequiredRole() throws {

    let token = FQAuthSessionToken(userID: userID,
                                   deviceName: "Xample",
                                   roles: ["admin"],
                                   expiration: ExpirationClaim(value: Date(timeIntervalSinceNow: 600)),
                                   iss: IssuerClaim("com.example")
    )
    let adminToken = try app.jwt.signers.sign(token, kid: .authPrivateKey)

    let headers = HTTPHeaders([("Authorization", "Bearer \(adminToken)")])
    try app.test(.GET, "admin-only", headers: headers) { response in
      XCTAssertEqual(response.status, .ok)
      XCTAssertEqual(String(buffer: response.body), #"1CB5E4AD-C9DC-4635-BC27-0AE1DA9637BD"#)
    }
  }
}
