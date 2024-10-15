import Vapor

final class SIWAController: RouteCollection {
  
  func boot(routes: RoutesBuilder) throws {
    routes.group("siwa") { siwa in
      siwa.post("authorize", use: self.authorize)
      siwa.post("notify", use: self.notify)
    }
  }
}
