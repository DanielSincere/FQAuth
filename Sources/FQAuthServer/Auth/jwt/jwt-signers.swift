import JWT

extension JWTSigners {
  func useAuthPrivate() {
    self.use(.es512(key: .authPrivateKey),
             kid: .authPrivateKey,
             isDefault: true)
  }

  func useAppleServicesKey() {
    // https://developer.apple.com/documentation/sign_in_with_apple/generate_and_validate_tokens
    // ECDSA with the P-256 curve and the SHA-256 hash algorithm
    // "alg": "ES256",
    self.use(.es256(key: .appleServicesKey),
             kid: .appleServicesKey,
             isDefault: false)
  }
}
