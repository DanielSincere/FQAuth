import Vapor
import JWTKit
import Fluent
import SQLKit
import PostgresNIO

extension SIWAController {
  
  private struct RequestBody: Content {
    let appleIdentityToken: String
    let authorizationCode: String
    let deviceName: String
    let firstName: String
    let lastName: String
  }

  func authorize(req: Request) -> EventLoopFuture<AuthResponse> {

    return self.decodeRequestBody(req: req)
      .flatMap { requestBody in
        return req.jwt.apple.verify(
          requestBody.appleIdentityToken,
          applicationIdentifier: EnvVars.appleAppId.loadOrFatal()
        )
        .flatMap { (appleIdentityToken: AppleIdentityToken) in
          return self.generateAppleRefreshToken(authorizationCode: requestBody.authorizationCode, req: req)
            .flatMap { appleTokenResponse in
              return UserModel.findByAppleUserId(appleIdentityToken.subject.value, db: req.db)
                .flatMap { maybeUser in
                  if let userModel = maybeUser {
                    return self.signIn(
                      userModel: userModel,
                      requestBody: requestBody,
                      appleIdentityToken: appleIdentityToken,
                      appleTokenResponse: appleTokenResponse,
                      req: req)
                  } else {
                    return self.signUp(
                      requestBody: requestBody,
                      appleIdentityToken: appleIdentityToken,
                      appleTokenResponse: appleTokenResponse,
                      req: req)
                  }
                }
            }
        }
      }
  }
  
  private func decodeRequestBody(req: Request) -> EventLoopFuture<RequestBody> {
    do {
      let requestBody = try req.content.decode(RequestBody.self)
      return req.eventLoop.makeSucceededFuture(requestBody)
    } catch {
      return req.eventLoop.makeFailedFuture(error)
    }
  }

  private func generateAppleRefreshToken(authorizationCode: String, req: Request) -> EventLoopFuture<AppleTokenResponse> {
    SIWAClient(request: req)
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
                      req: Request) -> EventLoopFuture<AuthResponse> {
    guard let siwa = userModel.$siwa.wrappedValue, let userId = userModel.id else {
      return req.eventLoop.makeFailedFuture(Abort(.forbidden))
    }

    siwa.encryptedAppleRefreshToken = DBSeal().seal(string: appleTokenResponse.refresh_token)
    return siwa.update(on: req.db).flatMap { _ in
      return AuthHelper(req: req)
        .login(userId: userId,
               firstName: requestBody.firstName,
               lastName: requestBody.lastName,
               deviceName: requestBody.deviceName)
    }
  }

  private func signUp(requestBody: RequestBody,
                      appleIdentityToken: AppleIdentityToken,
                      appleTokenResponse: AppleTokenResponse,
                      req: Request) -> EventLoopFuture<AuthResponse> {
    
    self.requireEmail(appleIdentityToken: appleIdentityToken, eventLoop: req.eventLoop)
      .flatMap { email in
        return SIWASignUpRepo(request: req)
          .signUp(.init(email: email,
                        firstName: requestBody.firstName,
                        lastName: requestBody.lastName,
                        deviceName: requestBody.deviceName,
                        registrationMethod: .siwa,
                        appleUserId: appleIdentityToken.subject.value,
                        appleRefreshToken: appleTokenResponse.refresh_token))
          .flatMap { userId in
            AuthHelper(req: req)
              .login(userId: userId,
                     firstName: requestBody.firstName,
                     lastName: requestBody.lastName,
                     deviceName: requestBody.deviceName)
          }
      }
  }
}
