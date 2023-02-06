import Foundation
import QueuesRedisDriver
import Queues
import FluentPostgresDriver

struct EnqueueRefreshTokenJobsScheduledJob: ScheduledJob {
  func run(context: Queues.QueueContext) -> NIOCore.EventLoopFuture<Void> {

    Self.enqueueRefreshTokenJobsForAccountsThatNeedRefreshing(logger: context.logger, db: context.application.db(.psql))
  }

  static func enqueueRefreshTokenJobsForAccountsThatNeedRefreshing(logger: Logger, db: Database) -> EventLoopFuture<Void> {

    return db.eventLoop.future()
  }
}
