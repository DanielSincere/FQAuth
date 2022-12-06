import Vapor

extension Request.Services {
  var siwaClient: SIWAClient {
    LiveSIWAClient(request: request)
  }
}

extension Application.Services {
  var siwaClient: Application.Service<SIWAClient> {
    .init(application: application)
  }
}
