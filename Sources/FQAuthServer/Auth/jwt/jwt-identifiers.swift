import JWT

extension JWKIdentifier {
  public static let authPublicKey: Self = "auth-public-key"
  public static let authPrivateKey: Self = "auth-private-key"
  public static var appleKey: Self {
    .init(string: EnvVars.appleKeyId.loadOrFatal())
  }
}
