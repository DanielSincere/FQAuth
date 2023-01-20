import Vapor

public struct FQAuthAuthenticator: BearerAuthenticator {

  public func authenticate(
    bearer: BearerAuthorization,
    for request: Request
  ) -> EventLoopFuture<Void> {
    do {
      let token = try request.jwt.verify(bearer.token, as: FQAuthSessionToken.self)
      request.auth.login(token)
      return request.eventLoop.future()
    } catch {
      return request.eventLoop.makeFailedFuture(error)
    }
  }
}
