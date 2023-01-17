import Queues
import PostgresKit

struct ConsentRevokedJob: Job {

  typealias Payload = SIWAModel.IDValue

   func dequeue(_ context: QueueContext, _ payload: SIWAModel.IDValue) -> EventLoopFuture<Void> {

     return Self.go(payload: payload,
                    db: context.application.db(.psql) as! SQLDatabase)
   }

   func error(_ context: QueueContext, _ error: Error, _ payload: SIWAModel.IDValue) -> EventLoopFuture<Void> {

     context.logger.critical("got an error while run ConsentRevokedJob: \(error)")
     return context.eventLoop.future()
   }

  static func go(payload: SIWAModel.IDValue, db: SQLDatabase) -> EventLoopFuture<Void> {

    


    return db.eventLoop.future()
  }
}
