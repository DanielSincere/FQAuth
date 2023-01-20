import XCTest
import XCTVapor
import JWTKit
@testable import FQAuthMiddleware

final class FQAuthMiddlewareTests: XCTestCase {

  let privateKey = Data(base64Encoded: "LS0tLS1CRUdJTiBFQyBQQVJBTUVURVJTLS0tLS0KQmdVcmdRUUFJdz09Ci0tLS0tRU5EIEVDIFBBUkFNRVRFUlMtLS0tLQotLS0tLUJFR0lOIEVDIFBSSVZBVEUgS0VZLS0tLS0KTUlIY0FnRUJCRUlCTnZBWXJLYk9CR29KSE1kKzBUNjdlUWdWWXdhVXlVUDIxdDlrdURFa1lQLzI0NndVMEwyYwpqSmFNdUI3dHZvSXZkWHZFZnNHdkRpZyswbFM1OXRtUW5HdWdCd1lGSzRFRUFDT2hnWWtEZ1lZQUJBQ1d4d0xBCkRsVFk5alZvNXYvVmNCZkpIZzZjUXdWUHlvZXcwWkxtMWVvY01PUm9FZFZucEZVZ20xVWZSVkdFRXZrbHRpV0cKOU5mZFVoL25QajNRWWx5V3VBRGdlS0NBMDBZVHhZNzNKd1RUTUlvczlmRXFOblh6TjBJUXhWVUFmYjFpKzd2SApvVURJRTlXNk1zbG9mQ3F3ZVFmeXJxa0c5VXU3VWtJNWgyS1M4RmU2VFE9PQotLS0tLUVORCBFQyBQUklWQVRFIEtFWS0tLS0tCg==")!

  var userID: UUID = .init()
  var authorizedToken: String!
  var app: Application!

  override func setUpWithError() throws {
    app = Application(.testing)

    app.jwt.signers.use(.es512(key: try ECDSAKey.private(pem: privateKey)),
                        kid: .authPrivateKey,
                        isDefault: true)

    app.routes.group(FQAuthAuthenticator(),
                     FQAuthSessionToken.guardMiddleware(throwing: Abort(.unauthorized))) { secure in
      secure.get("hello") { req in
        
        return "hello"
      }
    }

    let token = FQAuthSessionToken(userID: userID,
                                   expiration: ExpirationClaim(value: Date(timeIntervalSinceNow: 600)))
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
      XCTAssertEqual(String(buffer: response.body), #"{"error":true,"reason":"Unauthorized"}"#)
    }
  }

  func testUnauthorizedToken() throws {

    let unauthorizedToken = "eyJhbGciOiJFUzUxMiIsInR5cCI6IkpXVCJ9.eyJ1c2VySUQiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMiwiZXhwIjoxNTE2MjY5MDIyfQ.AQ2k8FRDnt4dwwrvxtxGOJ-ThEbmC5q2G_KY-cOHZp_fN9Y9NTLpImLqEkCiXDt-jekz4ynuHn-Co53bV1GJfbeAAW3i6frDK8sQr2vrT2MI88swAi8JWHjKaH54hUJHKa67tNDzZtduOO1jquSB0975xWEg4LJmBSP92xp5P8fra38G"

    let headers = HTTPHeaders([("Authorization", "Bearer \(unauthorizedToken)")])
    try app.test(.GET, "hello", headers: headers) { response in
      XCTAssertEqual(response.status, .unauthorized)
      XCTAssertEqual(String(buffer: response.body), #"{"error":true,"reason":"signature verification failed"}"#)
    }
  }

  func testAuthorized() throws {
    let headers = HTTPHeaders([("Authorization", "Bearer \(authorizedToken!)")])
    try app.test(.GET, "hello", headers: headers) { response in
      XCTAssertEqual(response.status, .ok)
      XCTAssertEqual(String(buffer: response.body), #"hello"#)
    }
  }
}
