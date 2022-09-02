import Vapor
import JWTKit
import Fluent
import SQLKit
import PostgresNIO

final class SIWAController {

  func siwa(req: Request) throws -> EventLoopFuture<AuthResponse> {

    let siwaRequestBody = try req.content.decode(SiwaRequestBody.self)
    return req.jwt.apple.verify(
      siwaRequestBody.appleIdentityToken,
      applicationIdentifier: EnvVars.appleAppId.loadOrFatal()
    )
    .flatMap { (appleIdentityToken: AppleIdentityToken) in
      self.generateAppleRefreshToken(authorizationCode: siwaRequestBody.authorizationCode, req: req)
        .flatMap { appleTokenResponse in
          return UserModel.findByAppleUserId(appleIdentityToken.subject.value, db: req.db)
            .flatMap { maybeUser in
              if let userModel = maybeUser {
                return self.signIn(
                  userModel: userModel,
                  siwaRequestBody: siwaRequestBody,
                  appleIdentityToken: appleIdentityToken,
                  appleTokenResponse: appleTokenResponse,
                  req: req
                )
              } else {
                return self.signUp(
                  siwaRequestBody: siwaRequestBody,
                  appleIdentityToken: appleIdentityToken,
                  appleTokenResponse: appleTokenResponse,
                  req: req
                )
              }
            }
        }
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

    return eventLoop.makeFailedFuture(Abort(.failedDependency, headers: HTTPHeaders(), reason: "Email missing from Apple token", identifier: "email.missing", suggestedFixes: ["On appleid.apple.com, sign out of our app. Then try again."], range: nil, stackTrace: nil))
  }

  private func signIn(userModel: UserModel, siwaRequestBody: SiwaRequestBody, appleIdentityToken: AppleIdentityToken, appleTokenResponse: AppleTokenResponse, req: Request) -> EventLoopFuture<AuthResponse> {
    guard let siwa = userModel.$siwa.wrappedValue, let userId = userModel.id else {
      return req.eventLoop.makeFailedFuture(Abort(.forbidden))
    }

    siwa.encryptedAppleRefreshToken = DBSeal().seal(string: appleTokenResponse.refresh_token)
    return siwa.update(on: req.db).flatMap { _ in
      return AuthHelper(req: req)
        .login(userId: userId,
               firstName: siwaRequestBody.firstName,
               lastName: siwaRequestBody.lastName,
               deviceName: siwaRequestBody.deviceName)
    }
  }

  private func signUp(siwaRequestBody: SiwaRequestBody, appleIdentityToken: AppleIdentityToken, appleTokenResponse: AppleTokenResponse, req: Request) -> EventLoopFuture<AuthResponse> {

    self.requireEmail(appleIdentityToken: appleIdentityToken, eventLoop: req.eventLoop).flatMap { email in

      return SIWASignUpRepo(request: req)
        .signUp(.init(email: email,
                      firstName: siwaRequestBody.firstName,
                      lastName: siwaRequestBody.lastName,
                      deviceName: siwaRequestBody.deviceName,
                      registrationMethod: .siwa,
                      appleUserId: appleIdentityToken.subject.value,
                      appleRefreshToken: appleTokenResponse.refresh_token))
        .flatMap { userId in
          AuthHelper(req: req)
            .login(userId: userId,
                   firstName: siwaRequestBody.firstName,
                   lastName: siwaRequestBody.lastName,
                   deviceName: siwaRequestBody.deviceName)
        }
    }
  }
}

extension SIWAController: RouteCollection {

  func boot(routes: RoutesBuilder) throws {
    routes.post("siwa", use: siwa)
  }
}
