import JWT

extension JWK {
  static var authPublic: JWK {
    .ecdsa(
      .es512,
      identifier: .authPublicKey,
      x: ECDSAKey.authPrivateKey.parameters?.x,
      y: ECDSAKey.authPrivateKey.parameters?.y,
      curve: .p521,
      privateKey: nil)
  }
}
