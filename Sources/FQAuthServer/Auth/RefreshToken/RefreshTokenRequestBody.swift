import Vapor

struct RefreshTokenRequestBody: Content, Equatable {
  let refreshToken: String
  let newDeviceName: String
}
