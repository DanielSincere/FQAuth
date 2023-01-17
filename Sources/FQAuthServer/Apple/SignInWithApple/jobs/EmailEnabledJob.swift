import Queues
import PostgresKit
import FluentPostgresDriver

struct EmailEnabledJob: Job {

  func dequeue(_ context: Queues.QueueContext, _ payload: Payload) -> NIOCore.EventLoopFuture<Void> {

    Self.updateEmail(for: payload,
                     logger: context.logger,
                     db: context.application.db(.psql))
  }

  struct Payload: Codable, Equatable {
    let newEmail: String
    let appleUserID: String
  }

  static func updateEmail(for payload: Payload, logger: Logger, db: Database) -> EventLoopFuture<Void> {

    SIWAModel
      .findBy(appleUserId: payload.appleUserID, db: db)
      .flatMap { maybeSiwa in
        guard let siwa = maybeSiwa else {
          logger.info("Received 'email-enabled' for `\(payload.appleUserID)`, but we don't have that user")
          return db.eventLoop.future()
        }

        siwa.email = payload.newEmail
        return siwa.save(on: db)
    }
  }
}
