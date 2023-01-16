import Vapor
import JWTKit

extension SIWAController {
  
  func notify(request: Request) -> EventLoopFuture<HTTPStatus> {
    NotifyBody.decodeRequest(request)
      .flatMap { notifyBody in
        do {
          let payload = notifyBody.payload
          let notification = try request.jwt.verify(payload, as: SIWAServerNotification.self)
          return self.handle(notification: notification, request: request)
        } catch {
          return request.eventLoop.makeFailedFuture(error)
        }
      }
  }

  private func handle(notification: SIWAServerNotification, request: Request) -> EventLoopFuture<HTTPStatus> {
    switch notification.events.wrapped {
    case .accountDelete(let accountDelete):
      return request.eventLoop.future(.notImplemented)
    case .emailEnabled(let emailEnabled):
      return request.eventLoop.future(.notImplemented)
    case .emailDisabled(let emailDisabled):
      return request.eventLoop.future(.notImplemented)
    case .consentRevoked(let consentRevoked):
      return self.handle(consentRevoked: consentRevoked, request: request)
    }
  }

  func handle(consentRevoked: SIWAServerNotification.Event.ConsentRevoked, request: Request) -> EventLoopFuture<HTTPStatus> {

    SIWAModel
      .findBy(appleUserId: consentRevoked.sub.value, db: request.db(.psql))
      .flatMap { maybeModel in
        do {
          if let model = maybeModel {
            return request.queue
              .dispatch(
                ConsentRevokedJob.self,
                try model.requireID()
              ).map { HTTPStatus.ok }
          } else {
            return request.eventLoop.future(.notFound)
          }
        } catch {
          return request.eventLoop.makeFailedFuture(error)
        }
      }
  }
  
  struct NotifyBody: Content {
    let payload: String
  }
}
