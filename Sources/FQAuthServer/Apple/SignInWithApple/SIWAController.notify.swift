import Vapor

extension SIWAController {
  
  func notify(req: Request) -> EventLoopFuture<HTTPStatus> {
    req.eventLoop.makeSucceededFuture(.ok)
  }
}
