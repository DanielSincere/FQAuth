import Vapor
import JWTKit

public struct SIWAClient {

  let signers: JWTSigners
  let client: Client
  let eventLoop: EventLoop
  let logger: Logger

  public init(signers: JWTSigners, client: Client, eventLoop: EventLoop, logger: Logger) {
    self.signers = signers
    self.client = client
    self.eventLoop = eventLoop
    self.logger = logger
  }
  
  public init(request: Request) {
    self.signers = request.application.jwt.signers
    self.client = request.client
    self.eventLoop = request.eventLoop
    self.logger = request.logger
  }

  var clientId: String {
    EnvVars.appleAppId.loadOrFatal()
  }

  var clientSecret: EventLoopFuture<String> {
    do {
      let payload = ClientSecret(clientId: try EnvVars.appleAppId.loadOrThrow(),
                                 teamId: try EnvVars.appleTeamId.loadOrThrow())
      let string = try signers.sign(payload, kid: .appleServicesKey)
      return eventLoop.makeSucceededFuture(string)
    } catch {
      logger.critical("Cannot sign request to Apple: \(error.localizedDescription)")
      return eventLoop.makeFailedFuture(error)
    }
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
  
  public func validateRefreshToken(token: String) -> EventLoopFuture<AppleAuthTokenResult> {
    self.clientSecret
      .flatMap { clientSecret in
        let body = AppleAuthTokenBody(client_id: self.clientId,
                                      client_secret: clientSecret,
                                      code: nil,
                                      grant_type: "refresh_token",
                                      refresh_token: token,
                                      redirect_uri: nil)
        
        return self.authToken(body: body)
      }
  }

  public func generateRefreshToken(code: String) -> EventLoopFuture<AppleTokenResponse> {
    self.clientSecret
      .flatMap { clientSecret in
        let body = AppleAuthTokenBody(client_id: self.clientId,
                                      client_secret: clientSecret,
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
}
