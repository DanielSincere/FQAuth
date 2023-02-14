import Vapor
import Queues
import Foundation
import FluentPostgresDriver

struct CleanupExpiredRefreshTokenScheduledJob: AsyncScheduledJob {
  func run(context: Queues.QueueContext) async throws {

    try await Self.executeSQL(
      db: context.application.db(.psql) as! SQLDatabase,
      logger: context.logger)
  }

  static func executeSQL(db: SQLDatabase, logger: Logger) async throws {
    let sql =
    """
    DELETE FROM "refresh_token"
    WHERE "expires_at" < CURRENT_TIMESTAMP
    """
    try await db.execute(sql: SQLRaw(sql)) { _ in }
  }
}
