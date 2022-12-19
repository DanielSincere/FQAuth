import Vapor

extension Application {
  func configureServices() {
    
    self.services.siwaClient.use { application in
      LiveSIWAClient(application: application)
    }
    
    self.services.siwaVerifierProvider.use { application in
      LiveSIWAVerifierProvider()
    }
  }
}
