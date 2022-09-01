import Vapor

struct RefreshTokenRequestBody: Content {
  let refreshToken: String
  let newDeviceName: String
}
