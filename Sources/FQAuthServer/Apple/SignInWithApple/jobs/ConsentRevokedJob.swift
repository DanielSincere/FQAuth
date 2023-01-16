import Queues

struct ConsentRevokedJob: Job {

  typealias Payload = SIWAModel.IDValue

   func dequeue(_ context: QueueContext, _ payload: SIWAModel.IDValue) -> EventLoopFuture<Void> {
       // This is where you would send the email
       return context.eventLoop.future()
   }

   func error(_ context: QueueContext, _ error: Error, _ payload: SIWAModel.IDValue) -> EventLoopFuture<Void> {
       // If you don't want to handle errors you can simply return a future. You can also omit this function entirely.
       return context.eventLoop.future()
   }
}
