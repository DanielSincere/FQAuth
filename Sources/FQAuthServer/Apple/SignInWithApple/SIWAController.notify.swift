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
      return request.queue.dispatch(SIWAAccountDeletedJob.self, accountDelete.sub.value)
      .map { .ok }
    case .emailEnabled(let emailEnabled):
      return request.queue.dispatch(EmailEnabledJob.self,
                                    EmailEnabledJob.Payload(
                                      newEmail: emailEnabled.email,
                                      appleUserID: emailEnabled.sub.value))
      .map { .ok }
    case .emailDisabled(let emailDisabled):
      return request.eventLoop.future(.notImplemented)
    case .consentRevoked(let consentRevoked):
      return request.queue.dispatch(ConsentRevokedJob.self, consentRevoked.sub.value)
      .map { .ok }
    }
  }

  struct NotifyBody: Content {
    let payload: String
  }
}
