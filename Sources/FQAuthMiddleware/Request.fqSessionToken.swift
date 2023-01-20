import Vapor

extension Request {

  public var fqSessionToken: FQAuthSessionToken? {
    self.auth.get(FQAuthSessionToken.self)
  }
}
