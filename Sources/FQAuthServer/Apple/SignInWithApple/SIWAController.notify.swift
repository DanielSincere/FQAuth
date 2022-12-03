import Vapor
import JWTKit

extension SIWAController {
  
  func notify(request: Request) -> EventLoopFuture<HTTPStatus> {
    
    NotifyBody.decodeRequest(request)
      .flatMapThrowing { notifyBody in
        
        let notification = try request.jwt.verify(notifyBody.payload, as: SIWAServerNotification.self)
        
        print(notification.events)
        return .ok
      }
  }
  
  struct NotifyBody: Content {
    let payload: String
  }
}
