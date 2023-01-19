import Vapor

public struct FQAuthMiddleware: Middleware {
  public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
    guard let _ = request.auth.get(FQAuthSessionToken.self) else {
      return request.eventLoop.future(error: Abort(.unauthorized))
    }
    return next.respond(to: request)
  }
}
