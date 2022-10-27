import Vapor

enum EnvVars: String, CaseIterable {
  
  // generate with `swish generate-jwt-key`
  case authPrivateKey = "AUTH_PRIVATE_KEY"
  
  func loadOrFatal() -> String {
    guard let string = Environment.get(self.rawValue) else {
      fatalError("\(self.rawValue) not set in environment")
    }
    
    return string
  }
  
  func loadOrThrow() throws -> String {
    guard let string = Environment.get(self.rawValue) else {
      throw EnvVarMissingError(name: self.rawValue)
    }
    
    return string
  }
  
  struct EnvVarMissingError: Error {
    let name: String
  }
  
  struct EnvVarsMissingError: Error {
    let names: [String]
  }
  
  static func ensureAllPresent() throws {
    let names: [String] = Self.allCases
      .compactMap { envVar in
        do {
          _ = try envVar.loadOrThrow()
          return nil
        } catch {
          return envVar.rawValue
        }
      }
    
    if names.isEmpty {
      return
    }
    
    throw EnvVarsMissingError(names: names)
  }
}
