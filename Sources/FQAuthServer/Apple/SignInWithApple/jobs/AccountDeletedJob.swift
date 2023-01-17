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
    db.eventLoop.future()
  }
}
