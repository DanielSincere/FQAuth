import Foundation
import Vapor
import SQLKit

struct SIWAReadyForReverifyRepo {

  let logger: Logger
  let eventLoop: EventLoop
  let database: SQLDatabase

  init(request: Request) {
    self.logger = request.logger
    self.eventLoop = request.eventLoop
    self.database = request.db(.psql) as! SQLDatabase
  }

  init(application: Application) {
    self.logger = application.logger
    let db = application.db(.psql)
    self.database = db as! SQLDatabase
    self.eventLoop = db.eventLoop
  }

  init(logger: Logger, eventLoop: EventLoop, database: SQLDatabase) {
    self.logger = logger
    self.eventLoop = eventLoop
    self.database = database
  }

  func fetch(callback: @escaping (SIWAModel)->Void) -> EventLoopFuture<Void> {
    let sql = """
    (
      SELECT * FROM siwa
      WHERE siwa.attempted_refresh_result = 'initial'
      AND siwa.created_at < NOW() - INTERVAL '24 HOURS'
    ) UNION (
      SELECT * FROM siwa
      WHERE (
           siwa.attempted_refresh_result = 'failure'
        OR siwa.attempted_refresh_result = 'success'
      ) AND (
           siwa.attempted_refresh_at < NOW() - INTERVAL '24 HOURS'
        OR siwa.attempted_refresh_at IS NULL
      )
    )
    """

    return database.execute(sql: SQLRaw(sql)) { row in
      do {
        let model = try row.decode(model: SIWAModel.self)
        callback(model)
      } catch {
        database.logger.critical("couldn't decode SIWAModel")
      }

    }
  }
}
