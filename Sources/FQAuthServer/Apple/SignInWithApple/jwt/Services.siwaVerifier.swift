import Vapor
import JWTKit

extension Application.Services {
  var siwaVerifier: Application.Service<SIWAVerifier> {
    .init(application: application)
  }
}

extension Request.Services {
  var siwaVerifier: any SIWAVerifier {
    self.request.application.services.siwaVerifier.service.for(request)
  }
}
