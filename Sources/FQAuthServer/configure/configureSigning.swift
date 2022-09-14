import Vapor
import PostgresNIO

extension Application {

  func configureSigning() throws {
    _ = try self.jwt.apple.jwks.get(using: self.client, on: self.client.eventLoop).wait()

    self.jwt.signers.useAuthPrivate()    
    self.jwt.signers.useAppleServicesKey()
  }
}
