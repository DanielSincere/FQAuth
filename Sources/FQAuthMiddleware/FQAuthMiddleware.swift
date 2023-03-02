import Foundation
import Vapor

public struct FQAuthMiddleware: Middleware {

  let requiredRole: String?
  
  public func respond(to request: Vapor.Request, chainingTo next: Vapor.Responder) -> NIOCore.EventLoopFuture<Vapor.Response> {
    
    FQAuthAuthenticator()
      .authenticate(request: request)
      .flatMap { () in
        guard let token = request.auth.get(FQAuthSessionToken.self) else {
          return request.eventLoop.makeFailedFuture(Abort(.unauthorized))
        }
        if let requiredRole = requiredRole {
          guard token.roles.contains(requiredRole) else {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized))
          }
          return next.respond(to: request)
        } else {
          return next.respond(to: request)
        }
      }
  }

  public init(requiredRole: String? = nil) {
    self.requiredRole = requiredRole
  }
}
