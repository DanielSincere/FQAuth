import Queues
import PostgresKit
import FluentPostgresDriver

struct EmailEnabledJob: Job {
  func dequeue(_ context: Queues.QueueContext, _ payload: Payload) -> NIOCore.EventLoopFuture<Void> {
    context.eventLoop.future()
  }

  struct Payload: Codable, Equatable {
    let newEmail: String
    let appleUserID: String
  }
}
