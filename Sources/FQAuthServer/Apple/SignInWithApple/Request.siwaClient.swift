import Vapor

extension Request {
  #if DEBUG
  
  var siwaClient: SIWAClient {
    SIWAClient(request: self)
  }
  
  #else
  var siwaClient: SIWAClient {
    SIWAClient(request: self)
  }
  #endif
}
