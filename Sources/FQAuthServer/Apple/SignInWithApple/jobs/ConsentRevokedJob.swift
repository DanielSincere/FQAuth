import Queues
import PostgresKit
import FluentPostgresDriver

struct ConsentRevokedJob: Job {

  typealias Payload = String

  func dequeue(_ context: QueueContext, _ payload: String) -> EventLoopFuture<Void> {

    return Self.deactivateUser(with: payload,
                               logger: context.logger,
                               db: context.application.db(.psql))
  }

  static func deactivateUser(with appleUserID: String,
                             logger: Logger,
                             db: Database) -> EventLoopFuture<Void> {
    SIWAModel
      .query(on: db)
      .filter(\SIWAModel.$appleUserId, .equal, appleUserID)
      .with(\.$user)
      .first()
      .flatMap { maybeSiwa in
        guard let siwa = maybeSiwa else {
          logger.critical("Apple sent us \(appleUserID) but we don't have it ConsentRevokedJob")
          return db.eventLoop.future()
        }
        siwa.encryptedAppleRefreshToken = nil
        siwa.user.status = .deactivated
        return siwa.save(on: db).and(siwa.user.save(on: db))
          .transform(to: ())
      }
  }
}
