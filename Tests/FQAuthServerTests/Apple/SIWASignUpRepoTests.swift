import XCTest
@testable import FQAuthServer
import FluentPostgresDriver

final class SIWASignUpRepoTests: XCTestCase {
  
  var repo: SIWASignUpRepo!
  var eventLoopGroup: EventLoopGroup!
  var threadPool: NIOThreadPool!
  
  override func setUpWithError() throws {
    let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    let threadPool = NIOThreadPool(numberOfThreads: 1)
    threadPool.start()
    
    let eventLoop = eventLoopGroup.next()
    
    let config = try PostgresConfiguration.for(.testing)
    let databases = Databases(threadPool: threadPool, on: eventLoopGroup)
    databases.use(.postgres(configuration: config), as: .psql)
    
    let logger = Logger(label: "test")
    let database = databases.database(.psql, logger: logger, on: eventLoop)
    let repo = SIWASignUpRepo(logger: logger, eventLoop: eventLoop, database: database as! SQLDatabase)
    
    self.repo = repo
    self.eventLoopGroup = eventLoopGroup
    self.threadPool = threadPool
  }
  
  override func tearDownWithError() throws {
    try eventLoopGroup?.syncShutdownGracefully()
    try threadPool?.syncShutdownGracefully()
  }
  
  
  func testSignUp() throws {
    print("eeeeeee")
  }
}
