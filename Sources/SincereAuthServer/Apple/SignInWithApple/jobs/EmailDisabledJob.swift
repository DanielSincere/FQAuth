import Queues
import PostgresKit
import FluentPostgresDriver

struct EmailDisabledJob: Job {

  func dequeue(_ context: Queues.QueueContext, _ payload: Payload) -> NIOCore.EventLoopFuture<Void> {

    Self.removeEmail(for: payload,
                     logger: context.logger,
                     db: context.application.db(.psql))
  }

  struct Payload: Codable, Equatable {
    let email: String
    let appleUserID: String
  }

  static func removeEmail(for payload: Payload, logger: Logger, db: Database) -> EventLoopFuture<Void> {

    SIWAModel
      .findBy(appleUserId: payload.appleUserID, db: db)
      .flatMap { maybeSiwa in
        guard let siwa = maybeSiwa else {

          logger.info("Received 'email-disabled' for `\(payload.appleUserID)`, but we don't have that user")
          return db.eventLoop.future()
        }

        guard siwa.email == payload.email else {
          logger.info("Received 'email-disabled' for `\(payload.appleUserID)`, but we don't have that email")
          return db.eventLoop.future()
        }

        siwa.email = nil
        return siwa.save(on: db)
      }
  }
}
