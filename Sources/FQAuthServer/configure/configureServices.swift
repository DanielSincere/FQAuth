import Vapor

extension Application {
  func configureServices() {
    
    self.services.siwaClient.use { application in
      LiveSIWAClient(application: application)
    }
    
//    self.services.siwaVerifier.use { application in
//      LiveSIWAVerifier(application: application)
//    }
  }
}
