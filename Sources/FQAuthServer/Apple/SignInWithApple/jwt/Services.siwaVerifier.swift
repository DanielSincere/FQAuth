import Vapor
import JWTKit

extension Application.Services {
  var siwaVerifierProvider: Application.Service<SIWAVerifierProvider> {
    .init(application: application)
  }
}

extension Request.Services {
  var siwaVerifier: any SIWAVerifier {
    self.request.application.services.siwaVerifierProvider.service.for(request)
  }
}
