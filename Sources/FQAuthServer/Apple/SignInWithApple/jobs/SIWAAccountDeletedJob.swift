import Foundation
import Queues
import FluentPostgresDriver

struct SIWAAccountDeletedJob: Job {
  typealias Payload = String

  func dequeue(_ context: Queues.QueueContext, _ payload: String) -> NIOCore.EventLoopFuture<Void> {
    SIWAAccountDeletedJob.deleteSIWAAccount(appleUserID: payload,
                                            logger: context.logger,
                                            db: context.application.db(.psql))
  }

  static func deleteSIWAAccount(appleUserID: String,
                                logger: Logger,
                                db: Database) -> EventLoopFuture<Void> {
    UserModel
      .findByAppleUserId(appleUserID, db: db)
      .flatMap { maybeUser in

        guard let user = maybeUser else {
          return db.eventLoop.future()
        }

        user.status = .deactivated
        return user.save(on: db)
      }
      .flatMapAlways { _ in
        SIWAModel
          .findBy(appleUserId: appleUserID, db: db)
          .flatMap { maybeSiwa in
            guard let siwa = maybeSiwa else {
              return db.eventLoop.future()
            }
            return siwa.delete(on: db)
        }
      }
  }
}
