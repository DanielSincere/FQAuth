@testable import FQAuthServer
import XCTVapor
import XCTest

final class RoutesTests: XCTestCase {

  func testHealthy() throws {
    let app = Application(.testing)
    defer {
      app.shutdown()
    }
    try app.routes()

    let response = try app.sendRequest(.GET, "healthy")
    XCTAssertEqual(response.status, .ok)
  }
}
