import Foundation
import JWTKit
import JWT

extension JWKIdentifier {
  public static let authPublicKey: Self = "auth-public-key"
  public static let authPrivateKey: Self = "auth-private-key"
}

extension JWTSigners {
  public func useAuthPrivate() {
    self.use(.es512(key: .authPrivateKey),
             kid: .authPrivateKey,
             isDefault: true)
  }
}

extension ECDSAKey {
  static var authPrivateKey: ECDSAKey {
    ECDSAKey.load(fromEnvVar: .authPrivateKey)
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
