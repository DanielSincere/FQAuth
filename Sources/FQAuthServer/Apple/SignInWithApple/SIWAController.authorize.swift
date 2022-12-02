import Vapor
import JWTKit

extension SIWAController {
  
  private struct RequestBody: Content {
    let appleIdentityToken: String
    let authorizationCode: String
    let deviceName: String
    let firstName: String
    let lastName: String
  }

  func authorize(request: Request) -> EventLoopFuture<AuthResponse> {

    return RequestBody.decodeRequest(request)
      .flatMap { requestBody in
        return request.jwt.apple.verify(
          requestBody.appleIdentityToken,
          applicationIdentifier: EnvVars.appleAppId.loadOrFatal()
        )
        .flatMap { (appleIdentityToken: AppleIdentityToken) in
          return self.generateAppleRefreshToken(authorizationCode: requestBody.authorizationCode, request: request)
            .flatMap { appleTokenResponse in
              return UserModel.findByAppleUserId(appleIdentityToken.subject.value, db: request.db)
                .flatMap { maybeUser in
                  if let userModel = maybeUser {
                    return self.signIn(
                      userModel: userModel,
                      requestBody: requestBody,
                      appleIdentityToken: appleIdentityToken,
                      appleTokenResponse: appleTokenResponse,
                      request: request)
                  } else {
                    return self.signUp(
                      requestBody: requestBody,
                      appleIdentityToken: appleIdentityToken,
                      appleTokenResponse: appleTokenResponse,
                      request: request)
                  }
                }
            }
        }
      }
  }
  
  private func generateAppleRefreshToken(authorizationCode: String, request: Request) -> EventLoopFuture<AppleTokenResponse> {
    SIWAClient(request: request)
      .generateRefreshToken(code: authorizationCode)
  }

  private func requireEmail(appleIdentityToken: AppleIdentityToken, eventLoop: EventLoop) -> EventLoopFuture<String> {
    if let email = appleIdentityToken.email {
      return eventLoop.makeSucceededFuture(email)
    }

    return eventLoop.makeFailedFuture(Abort(.failedDependency,
                                            headers: HTTPHeaders(),
                                            reason: "Email missing from Apple token",
                                            identifier: "email.missing",
                                            suggestedFixes: ["On appleid.apple.com, sign out of our app. Then try again."],
                                            range: nil,
                                            stackTrace: nil))
  }

  private func signIn(userModel: UserModel,
                      requestBody: RequestBody,
                      appleIdentityToken: AppleIdentityToken,
                      appleTokenResponse: AppleTokenResponse,
                      request: Request) -> EventLoopFuture<AuthResponse> {
    guard let siwa = userModel.$siwa.wrappedValue, let userId = userModel.id else {
      return request.eventLoop.makeFailedFuture(Abort(.forbidden))
    }

    siwa.encryptedAppleRefreshToken = DBSeal().seal(string: appleTokenResponse.refresh_token)
    return siwa.update(on: request.db).flatMap { _ in
      return AuthHelper(request: request)
        .login(userId: userId,
               firstName: requestBody.firstName,
               lastName: requestBody.lastName,
               deviceName: requestBody.deviceName)
    }
  }

  private func signUp(requestBody: RequestBody,
                      appleIdentityToken: AppleIdentityToken,
                      appleTokenResponse: AppleTokenResponse,
                      request: Request) -> EventLoopFuture<AuthResponse> {
    
    self.requireEmail(appleIdentityToken: appleIdentityToken, eventLoop: request.eventLoop)
      .flatMap { email in
        return SIWASignUpRepo(request: request)
          .signUp(.init(email: email,
                        firstName: requestBody.firstName,
                        lastName: requestBody.lastName,
                        deviceName: requestBody.deviceName,
                        registrationMethod: .siwa,
                        appleUserId: appleIdentityToken.subject.value,
                        appleRefreshToken: appleTokenResponse.refresh_token))
          .flatMap { userId in
            AuthHelper(request: request)
              .login(userId: userId,
                     firstName: requestBody.firstName,
                     lastName: requestBody.lastName,
                     deviceName: requestBody.deviceName)
          }
      }
  }
}
