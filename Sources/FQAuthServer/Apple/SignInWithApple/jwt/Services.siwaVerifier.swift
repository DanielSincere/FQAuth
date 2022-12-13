import Vapor
import JWTKit

extension Application.Services {
  var siwaVerifier: Application.Service<SIWAVerifier> {
    .init(application: application)
  }
}

extension Request.Services {
  var siwaVerifier: SIWAVerifier {
    LiveSIWAVerifier(request: request)
  }
}
