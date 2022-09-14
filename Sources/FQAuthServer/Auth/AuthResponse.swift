import Vapor

struct AuthResponse: Content, Equatable {
  let user: User
  let refreshToken: String
  let accessToken: String

  struct User: Codable, Equatable {
    let id: UUID
    let firstName: String
    let lastName: String
  }
}
