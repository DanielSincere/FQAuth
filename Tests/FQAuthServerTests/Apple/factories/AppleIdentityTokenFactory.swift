import Foundation
import JWTKit

enum AppleIdentityTokenFixtures: String {

  case a = """
  {

  }
  """

  var decoded: AppleIdentityToken {
    try! JSONDecoder().decode(AppleIdentityToken.self, from: rawValue.data(using: .utf8)!)
  }
}
