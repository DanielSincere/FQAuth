import XCTest
@testable import SincereAuthServer

final class CryptoTests: XCTestCase {

    func testDBSeal() throws {
      let seal = DBSeal(base64EncodedKey: "9/Vk5Rlzctc5tyX0SCmIJaRzEg+QgwWjlTzD0LMPqNY=")
      let sealed = seal.seal(string: "hamburger")
      XCTAssertEqual(seal.unseal(string: sealed), "hamburger")
    }
}
