import Foundation
@testable import FQAuthServer
import JWTKit

struct FakeJWTSigners: JWTVerifying {

  let stub: JWTPayload
  func verify<Payload>(_ token: String, as payload: Payload.Type) throws -> Payload where Payload : JWTKit.JWTPayload {
    return stub as! Payload
  }
}
