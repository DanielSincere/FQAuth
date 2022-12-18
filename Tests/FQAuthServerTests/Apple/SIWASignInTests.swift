@testable import FQAuthServer
import XCTest
import Vapor
import JWTKit
import Foundation

final class SIWASignInTests: XCTestCase {
  
  var app: Application!
  
  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
    
    try app.autoRevert().wait()
    try app.autoMigrate().wait()
  }
  
  override func tearDownWithError() throws {
    app.shutdown()
  }
  
  func testSignIn() throws {
    
  }
}
