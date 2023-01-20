import Vapor

public struct FQAuthMiddleware: Middleware {
  public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {

    guard let _ = request.auth.get(FQAuthSessionToken.self) else {
      return request.eventLoop.future(error: Abort(.unauthorized))
    }
    return next.respond(to: request)
  }
}

struct FQAuthMiddlewareAuthenticator: BearerAuthenticator {

  func authenticate(
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
