import JWT
import Foundation

extension ECDSAKey {

  static var authPrivateKey: ECDSAKey {
    ECDSAKey.load(fromEnvVar: .authPrivateKey)
  }

  static var appleDeveloperKey: ECDSAKey {
    ECDSAKey.load(fromEnvVar: .appleDeveloperKey)
  }

  private static func load(fromEnvVar envVar: EnvVars) -> ECDSAKey {
    guard let data = Data(base64Encoded: envVar.loadOrFatal()) else {
      fatalError("Could not parse base64Encoded data for \(envVar)")
    }
    do {
      return try ECDSAKey.private(pem: data)
    } catch {
      fatalError("Could not parse ECDSAKey for \(envVar): \(error)")
    }
  }
}
