//
//  SIWAClientTests.swift
//  
//
//  Created by Daniel on 11/19/22.
//

import XCTest
import Vapor
@testable import FQAuthServer

final class SIWAClientTests: XCTestCase {
  
  var app: Application!
  override func setUpWithError() throws {
    self.app = Application(.testing)
    try app.configure()
  }
  
  override func tearDownWithError() throws {
    app.shutdown()
  }
  
  func testExample() throws {
    
    let httpClient = FakeClient(eventLoop: app.eventLoopGroup.next())
    let siwaClient = SIWAClient(signers: app.jwt.signers,
                                client: httpClient,
                                eventLoop: app.eventLoopGroup.next(),
                                logger: app.logger)
    
    let response = try siwaClient.generateRefreshToken(code: "code123").wait()
    
    let request: ClientRequest = try XCTUnwrap(httpClient.receivedRequest)
    XCTAssertEqual(request.url.string, "asd.comf")
  }
  
  
  class FakeClient: Client {
    var receivedRequest: ClientRequest?
    
    var eventLoop: NIOCore.EventLoop
    init(eventLoop: NIOCore.EventLoop) {
      self.eventLoop = eventLoop
    }
    
    func delegating(to eventLoop: NIOCore.EventLoop) -> Vapor.Client {
      self.eventLoop = eventLoop
      return self
    }
    
    func send(_ request: ClientRequest) -> EventLoopFuture<ClientResponse> {
      self.receivedRequest = request
      return eventLoop.makeSucceededFuture(ClientResponse())
    }
  }
}
