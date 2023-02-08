import Vapor
import Queues
import XCTest

extension Queue {
  func nextPayload<T: Decodable>(as: T.Type = T.self) throws -> (String, T) {
    let jobId1 = try XCTUnwrap(self.pop().wait())
    let job1 = try self.get(jobId1).wait()
    let payload1: T = try JSONDecoder().decode(T.self, from: ByteBuffer(bytes: job1.payload))
    return (job1.jobName, payload1)
  }
}
