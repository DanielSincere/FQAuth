import Crypto
import Foundation

final class DBSeal {

  func seal(string: String) -> String {
    try! ChaChaPoly.seal(string.data(using: .utf8)!,
                         using: key,
                         nonce: ChaChaPoly.Nonce()).combined.base64EncodedString()
  }

  func unseal(string: String) -> String {
    let sealedData = Data(base64Encoded: string)!
    let box = try! ChaChaPoly.SealedBox(combined: sealedData)
    let openedData = try! ChaChaPoly.open(box, using: key)
    return String(data: openedData, encoding: .utf8)!
  }

  let key: SymmetricKey
  init(base64EncodedKey: String) {
    self.key = SymmetricKey(data: Data(base64Encoded: base64EncodedKey)!)
  }

  convenience init() {
    self.init(base64EncodedKey: EnvVars.dbSymmetricKey.loadOrFatal())
  }
}
