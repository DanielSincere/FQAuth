@testable import FQAuthServer
import XCTest
import Vapor

final class SIWAAuthorizeTests: XCTestCase {

  var app: Application!
  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
  }
  
  override func tearDownWithError() throws {
    app.shutdown()
  }

  func testSignUp() throws {
    
  }

}
