import Foundation
import Vapor

public struct FQAuthMiddleware: Middleware {
  
  public func respond(to request: Vapor.Request, chainingTo next: Vapor.Responder) -> NIOCore.EventLoopFuture<Vapor.Response> {
    
    FQAuthAuthenticator()
      .authenticate(request: request)
      .flatMap { () in
        guard request.auth.has(FQAuthSessionToken.self) else {
          return request.eventLoop.makeFailedFuture(Abort(.unauthorized))
        }
        return next.respond(to: request)
      }
  }
}
