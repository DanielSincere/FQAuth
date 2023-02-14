import JWT

extension JWKIdentifier {
  public static let authPublicKey: Self = "auth-public-key"
  public static let authPrivateKey: Self = "auth-private-key"
  public static var appleDeveloperKey: Self {
    .init(string: EnvVars.appleDeveloperKeyId.loadOrFatal())
  }
}
