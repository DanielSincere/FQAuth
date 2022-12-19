import Vapor
import JWTKit

extension SIWAController {
  
  func notify(request: Request) -> EventLoopFuture<HTTPStatus> {
    
    NotifyBody.decodeRequest(request)
      .flatMapThrowing { notifyBody in
        
        let notification = try request.jwt.verify(notifyBody.payload, as: SIWAServerNotification.self)
        
        switch notification.events.wrapped {
        case .accountDelete(let accountDelete):
          _ = SIWAModel.findBy(appleUserId: accountDelete.sub.value, db: request.db(.psql))
          
        case .emailEnabled(let emailEnabled):
          break
        case .emailDisabled(let emailDisabled):
          break
        case .consentRevoked(let consentRevoked):
          break
        }
        return .ok
      }
  }
  
  struct NotifyBody: Content {
    let payload: String
  }
}
