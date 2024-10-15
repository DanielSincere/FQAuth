import JWT

extension JWKIdentifier {
  public static let authPublicKey: Self = "auth-public-key"
  public static let authPrivateKey: Self = "auth-private-key"
  public static var appleServicesKey: Self {
    .init(string: EnvVars.appleServicesKeyId.loadOrFatal())
  }
}
