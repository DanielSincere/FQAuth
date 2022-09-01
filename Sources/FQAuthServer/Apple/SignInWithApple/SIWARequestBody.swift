import Vapor

struct SiwaRequestBody: Content {
  let appleIdentityToken: String
  let authorizationCode: String
  let deviceName: String
  let firstName: String
  let lastName: String
}
