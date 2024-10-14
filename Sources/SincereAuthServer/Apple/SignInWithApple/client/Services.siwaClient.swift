import Vapor

extension Application.Services {
  var siwaClient: Application.Service<SIWAClient> {
    .init(application: application)
  }
}

extension Request.Services {
  var siwaClient: SIWAClient {
    self.request.application.services.siwaClient.service.for(request)
  }
}
