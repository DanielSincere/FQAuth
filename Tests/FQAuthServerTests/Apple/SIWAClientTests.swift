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
    let httpClient = FakeClient(stubbedResponse: AppleFixtures.successfulSiwaResponse, eventLoop: app.eventLoopGroup.next())
    let siwaClient = SIWAClient(signers: app.jwt.signers,
                                client: httpClient,
                                eventLoop: app.eventLoopGroup.next(),
                                logger: app.logger)
    
    let _ = try siwaClient.generateRefreshToken(code: "code123").wait()
    
    let request: ClientRequest = try XCTUnwrap(httpClient.receivedRequest)
    XCTAssertEqual(request.url.string, "https://appleid.apple.com/auth/token")
    XCTAssertEqual(request.headers, HTTPHeaders([("content-type", "application/x-www-form-urlencoded; charset=utf-8")]))
    
    let urlEncodedFormString = try XCTUnwrap(request.body?.string)
    let body = try URLEncodedFormDecoder().decode(AppleAuthTokenBody.self, from: urlEncodedFormString)
    XCTAssertEqual(body.grant_type, "authorization_code")
    XCTAssertEqual(body.client_id, "com.fullqueuedeveloper.FQAuthSampleiOSApp")
    XCTAssertEqual(body.code, "code123")
    XCTAssertNil(body.redirect_uri)
    XCTAssertNil(body.refresh_token)
  }
  
  class FakeClient: Client {
    var receivedRequest: ClientRequest?
    
    let stubbedResponse: ClientResponse
    var eventLoop: NIOCore.EventLoop
    init(stubbedResponse: ClientResponse, eventLoop: NIOCore.EventLoop) {
      self.stubbedResponse = stubbedResponse
      self.eventLoop = eventLoop
    }
    
    func delegating(to eventLoop: NIOCore.EventLoop) -> Vapor.Client {
      self.eventLoop = eventLoop
      return self
    }
    
    func send(_ request: ClientRequest) -> EventLoopFuture<ClientResponse> {
      self.receivedRequest = request
      return eventLoop.makeSucceededFuture(stubbedResponse)
    }
  }
}
