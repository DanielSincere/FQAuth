import Vapor

//public struct FQAuthMiddleware: Middleware {
//  public let roles: Set<FQAuthRole>
//  public init(roles: Set<FQAuthRole> = Set(FQAuthRole.allCases)) {
//    self.roles = roles
//  }
//  
//  public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
//   let token = try request.auth.require(FQAuthSessionToken.self)
//    
//    roles.contains(token.role) else {
//      return request.eventLoop.future(error: Abort(.unauthorized))
//    }
//    return next.respond(to: request)
//  }
//}
