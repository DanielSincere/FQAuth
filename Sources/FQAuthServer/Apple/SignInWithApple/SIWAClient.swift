import Vapor
import JWTKit

public struct SIWAClient {

  let signers: JWTSigners
  let client: Client
  let eventLoop: EventLoop
  let logger: Logger

  public init(request: Request) {
    self.signers = request.application.jwt.signers
    self.client = request.client
    self.eventLoop = request.eventLoop
    self.logger = request.logger
  }

  public init(application: Application, eventLoop: EventLoop) {
    self.signers = application.jwt.signers
    self.client = application.client
    self.logger = application.logger
    self.eventLoop = eventLoop
  }

  var clientId: String {
    EnvVars.appleAppId.loadOrFatal()
  }

  var clientSecret: String {
    let payload = ClientSecret(clientId: EnvVars.appleAppId.loadOrFatal(),
                               teamId: EnvVars.appleTeamId.loadOrFatal())
    return try! signers.sign(payload, kid: .appleServicesKey)
  }


  // https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_rest_api/verifying_a_user
  // https://developer.apple.com/documentation/sign_in_with_apple/generate_and_validate_tokens

  internal func authToken(body: AppleAuthTokenBody) -> EventLoopFuture<AppleAuthTokenResult> {
    self.buildRequest(body)
      .flatMap(self.postRequest)
      .flatMap(self.interpretResponse)
  }

  private func postRequest(_ clientRequest: ClientRequest) -> EventLoopFuture<ClientResponse> {
    self.client.send(clientRequest)
  }

  private func interpretResponse(_ clientResponse: ClientResponse) -> EventLoopFuture<AppleAuthTokenResult> {
    do {
      if clientResponse.status == .ok {
        let tokenResponse = try clientResponse.content.decode(AppleTokenResponse.self)
        return self.eventLoop.makeSucceededFuture(.token(tokenResponse))
      } else {
        let appleError = try clientResponse.content.decode(AppleErrorResponse.self)
        return self.eventLoop.makeSucceededFuture(.error(appleError))
      }
    } catch {
      return self.eventLoop.makeFailedFuture(error)
    }
  }

  private func buildRequest(_ body: AppleAuthTokenBody) -> EventLoopFuture<ClientRequest> {
    do {
      let uri = URI(scheme: "https", host: "appleid.apple.com", path: "/auth/token")
      var clientRequest = ClientRequest(method: .POST, url: uri)
      try clientRequest.content.encode(body, as: .urlEncodedForm)
      return self.eventLoop.makeSucceededFuture(clientRequest)
    } catch {
      return self.eventLoop.makeFailedFuture(error)
    }
  }

  public func generateRefreshToken(code: String) -> EventLoopFuture<AppleTokenResponse> {

    let body = AppleAuthTokenBody(client_id: self.clientId,
                                  client_secret: self.clientSecret,
                                  code: code,
                                  grant_type: "authorization_code",
                                  refresh_token: nil,
                                  redirect_uri: nil)

    return self.authToken(body: body)
      .flatMap { result in
        switch result {
        case let .token(token):
          return self.eventLoop.makeSucceededFuture(token)
        case let .error(appleError):
          return self.eventLoop.makeFailedFuture(appleError)
        }
      }
  }
}
