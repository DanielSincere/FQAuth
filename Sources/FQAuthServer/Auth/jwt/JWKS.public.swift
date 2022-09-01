import JWT
extension JWKS {
  static var `public`: JWKS {
    JWKS(keys: [
      .authPublic,
    ])
  }
}
