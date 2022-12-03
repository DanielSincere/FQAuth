import Vapor
import PostgresNIO

extension Application {

  func configureSigning() throws {
    self.jwt.apple.applicationIdentifier = try EnvVars.appleAppId.loadOrThrow()

    let appleJWKS = try self.jwt.apple.jwks.get(using: self.client, on: self.client.eventLoop).wait()
    try self.jwt.signers.use(jwks: appleJWKS)

    self.jwt.signers.useAuthPrivate()    
    self.jwt.signers.useAppleServicesKey()
  }
}
