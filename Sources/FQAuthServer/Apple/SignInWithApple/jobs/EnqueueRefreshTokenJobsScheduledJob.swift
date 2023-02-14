import Foundation
import QueuesRedisDriver
import Queues
import FluentPostgresDriver

struct SIWAReadyForReverifyScheduledJob: AsyncScheduledJob {
  func run(context: Queues.QueueContext) async throws {
    try await Self.enqueueJobs(
      logger: context.logger,
      db: context.application.db(.psql),
      queue: context.queue)
  }

  static func enqueueJobs(logger: Logger, db: Database, queue: Queue) async throws {

    let repo = SIWAReadyForReverifyRepo(logger: logger,
                                        eventLoop: db.eventLoop,
                                        database: db as! SQLDatabase)

    let siwaModels = try await repo.fetch()
    for siwaModel in siwaModels {
      try await queue.dispatch(RefreshTokenJob.self, try! siwaModel.requireID())
    }
  }
}
