import Vapor

extension Application {
  func resetQueue() throws {
    while try self.queues.queue.pop().wait() != nil { }
  }
}
