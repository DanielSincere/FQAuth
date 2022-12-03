import JWTKit

public struct SIWAServerNotification: JWTPayload {

  public let iss: IssuerClaim
  public let aud: AudienceClaim
  public let iat: IssuedAtClaim
  public let jti: IDClaim
  public let events: AppleStringWrapped<Event>

  public func verify(using signer: JWTSigner) throws {
    let appleAppId = try EnvVars.appleAppId.loadOrThrow()
    try aud.verifyIntendedAudience(includes: appleAppId)

    guard iss.value == "https://appleid.apple.com" else {
      throw JWTError.generic(identifier: "iss", reason: "not from Apple")
    }

    guard iat.value < Date() else {
      throw JWTError.generic(identifier: "iat", reason: "in the future")
    }
  }

  public enum EventType: String, Codable {
    case emailDisabled = "email-disabled"
    case emailEnabled = "email-enabled"
    case accountDelete = "account-delete"
    case consentRevoked = "consent-revoked"
  }

  public enum Event: Codable {
    case emailEnabled(EmailEnabled)
    case emailDisabled(EmailDisabled)
    case consentRevoked(ConsentRevoked)
    case accountDelete(AccountDelete)

    public struct EmailEnabled: Codable {
      let sub: SubjectClaim
      let eventTime: IssuedAtClaim
      let email: String
      let isPrivateEmail: AppleJsonBool

      public enum CodingKeys: String, CodingKey {
        case sub
        case eventTime = "event_time"
        case email
        case isPrivateEmail = "is_private_email"
      }
    }

    public struct EmailDisabled: Codable {
      public let sub: SubjectClaim
      public let eventTime: IssuedAtClaim

      public enum CodingKeys: String, CodingKey {
        case sub
        case eventTime = "event_time"
      }
    }

    public struct ConsentRevoked: Codable {
      public let sub: SubjectClaim
      public let eventTime: IssuedAtClaim

      public enum CodingKeys: String, CodingKey {
        case sub
        case eventTime = "event_time"
      }
    }

    public struct AccountDelete: Codable {
      public let sub: SubjectClaim
      public let eventTime: IssuedAtClaim

      public enum CodingKeys: String, CodingKey {
        case sub
        case eventTime = "event_time"
      }
    }

    public init(from decoder: Decoder) throws {

      struct TypeOnly: Codable {
        let type: EventType
      }

      let type: EventType = try TypeOnly(from: decoder).type
      switch type {
      case .emailEnabled:
        self = .emailEnabled(try EmailEnabled(from: decoder))
      case .emailDisabled:
        self = .emailDisabled(try EmailDisabled(from: decoder))
      case .accountDelete:
        self = .accountDelete(try AccountDelete(from: decoder))
      case .consentRevoked:
        self = .consentRevoked(try ConsentRevoked(from: decoder))
      }
    }
  }
}
