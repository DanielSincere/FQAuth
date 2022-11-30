import Vapor

public enum AppleAuthTokenResult {
  case token(AppleTokenResponse)
  case error(AppleErrorResponse)
  
  static func interpret(clientResponse: ClientResponse, on eventLoop: EventLoop) -> EventLoopFuture<Self> {
    do {
      if clientResponse.status == .ok {
        let tokenResponse = try clientResponse.content.decode(AppleTokenResponse.self)
        return eventLoop.makeSucceededFuture(.token(tokenResponse))
      } else {
        let appleError = try clientResponse.content.decode(AppleErrorResponse.self)
        return eventLoop.makeSucceededFuture(.error(appleError))
      }
    } catch {
      return eventLoop.makeFailedFuture(error)
    }
  }
}
