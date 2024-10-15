import Vapor

final class LoginController {

  func login(req: Request) async throws -> View {
    let login = LoginView(appleidSigninClientId: try EnvVars.appleTeamId.load(),
                          appleidSigninScope: "code id_token name email",
                          appleidSigninRedirectUri: "https://redirectUri",
                          appleidSigninState: "stat",
                          appleidSigninNonce: "nonce")
    return try await req.view.render("Login/login", login)
  }

  struct LoginView: Codable {
    let appleidSigninClientId: String
    let appleidSigninScope: String
    let appleidSigninRedirectUri: String
    let appleidSigninState: String
    let appleidSigninNonce: String
  }
}

extension LoginController: RouteCollection {

  func boot(routes: RoutesBuilder) throws {
    routes.get("login", use: self.login(req:))
  }
}
