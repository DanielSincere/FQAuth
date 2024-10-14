import Foundation
import XCTest
import Vapor
@testable import SincereAuthServer

final class DependencyInjectionTests: XCTestCase {
  
  func testInjection() throws {
    
    let app = Application(.testing)
    defer {
      app.shutdown()
    }
    try app.configure()
    
    print(app.services.siwaClient.service)
  }
}
