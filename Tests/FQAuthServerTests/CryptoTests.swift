import XCTest
@testable import FQAuthServer
import Vapor

final class CryptoTests: XCTestCase {

    func testDbSymmetricKey() throws {
      let app = Application(.testing)
      try app.configure()
      defer {
        app.shutdown()
      }
      let sealed = DB.seal(string: "hamburger")
      XCTAssertEqual(DB.unseal(string: sealed), "hamburger")
    }
}
