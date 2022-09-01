import Crypto
import Foundation

enum DB {

  static func seal(string: String) -> String {
    try! ChaChaPoly.seal(string.data(using: .utf8)!,
                         using: Self.key,
                         nonce: ChaChaPoly.Nonce()).combined.base64EncodedString()
  }

  static func unseal(string: String) -> String {
    let sealedData = Data(base64Encoded: string)!
    let box = try! ChaChaPoly.SealedBox(combined: sealedData)
    let openedData = try! ChaChaPoly.open(box, using: Self.key)
    return String(data: openedData, encoding: .utf8)!
  }

  private static var key: SymmetricKey {
    .init(data: Data(base64Encoded: EnvVars.dbSymmetricKey.loadOrFatal())!)
  }
}
