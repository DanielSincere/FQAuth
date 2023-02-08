import Foundation
import Queues

struct RefreshTokenJob: Job {
  typealias Payload = SIWAModel.IDValue

  func dequeue(_ context: Queues.QueueContext, _ payload: SIWAModel.IDValue) -> NIOCore.EventLoopFuture<Void> {

    context.eventLoop.future()
  }
}
