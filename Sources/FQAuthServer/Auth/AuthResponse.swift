import Vapor

struct AuthResponse: Codable, Content {
  let user: User
  let refreshToken: String
  let accessToken: String

  struct User: Codable {
    let id: UUID
    let firstName: String
    let lastName: String
  }
}
