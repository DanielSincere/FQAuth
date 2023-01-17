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
    db.eventLoop.future()
  }
}
