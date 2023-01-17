import Queues
import PostgresKit
import FluentPostgresDriver

struct ConsentRevokedJob: Job {

  typealias Payload = SIWAModel.IDValue

  func dequeue(_ context: QueueContext, _ payload: SIWAModel.IDValue) -> EventLoopFuture<Void> {

    return Self.go(payload: payload,
                   db: context.application.db(.psql))
  }

  func error(_ context: QueueContext, _ error: Error, _ payload: SIWAModel.IDValue) -> EventLoopFuture<Void> {

    context.logger.critical("got an error while run ConsentRevokedJob: \(error)")
    return context.eventLoop.future()
  }

  static func go(payload siwaID: SIWAModel.IDValue, db: Database) -> EventLoopFuture<Void> {

    return SIWAModel
      .query(on: db)
      .filter(\SIWAModel.$id, .equal, siwaID)
      .with(\.$user)
      .first()
      .flatMap({ maybeSiwa in
        guard let siwa = maybeSiwa else {
          return db.eventLoop.makeFailedFuture(SIWAMissingError())
        }
        siwa.encryptedAppleRefreshToken = nil
        siwa.user.status = .deactivated
        return siwa.save(on: db).and(siwa.user.save(on: db))
          .transform(to: ())
      })
  }

  struct SIWAMissingError: Error { }
}
