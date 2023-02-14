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
    
    public var accountDelete: AccountDelete? {
      switch self {
      case .accountDelete(let accountDelete): return accountDelete
      case .emailEnabled, .emailDisabled, .consentRevoked: return nil
      }
    }
    
    public var emailEnabled: EmailEnabled? {
      switch self {
      case .emailEnabled(let emailEnabled): return emailEnabled
      case .accountDelete, .emailDisabled, .consentRevoked: return nil
      }
    }
    
    public var emailDisabled: EmailDisabled? {
      switch self {
      case .emailDisabled(let emailDisabled): return emailDisabled
      case .accountDelete, .emailEnabled, .consentRevoked: return nil
      }
    }
    
    public var consentRevoked: ConsentRevoked? {
      switch self {
      case .consentRevoked(let consentRevoked): return consentRevoked
      case .accountDelete, .emailEnabled, .emailDisabled: return nil
      }
    }

    public struct EmailEnabled: Codable {
      public let type: EventType = .emailEnabled
      public let sub: SubjectClaim
      public let eventTime: IssuedAtClaim
      public let email: String
      public let isPrivateEmail: AppleJsonBool

      public enum CodingKeys: String, CodingKey {
        case type
        case sub
        case eventTime = "event_time"
        case email
        case isPrivateEmail = "is_private_email"
      }
    }

    public struct EmailDisabled: Codable {
      public let type: EventType = .emailDisabled
      public let sub: SubjectClaim
      public let eventTime: IssuedAtClaim
      public let email: String
      public let isPrivateEmail: AppleJsonBool

      public enum CodingKeys: String, CodingKey {
        case type
        case sub
        case eventTime = "event_time"
        case email
        case isPrivateEmail = "is_private_email"
      }
    }

    public struct ConsentRevoked: Codable {
      public let type: EventType = .consentRevoked
      public let sub: SubjectClaim
      public let eventTime: IssuedAtClaim

      public enum CodingKeys: String, CodingKey {
        case type
        case sub
        case eventTime = "event_time"
      }
    }

    public struct AccountDelete: Codable {
      public let type: EventType = .accountDelete
      public let sub: SubjectClaim
      public let eventTime: IssuedAtClaim

      public enum CodingKeys: String, CodingKey {
        case type
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

    public func encode(to encoder: Encoder) throws {
      switch self {
      case .accountDelete(let accountDelete):
        try accountDelete.encode(to: encoder)
      case .emailEnabled(let emailEnabled):
        try emailEnabled.encode(to: encoder)
      case .emailDisabled(let emailDisabled):
        try emailDisabled.encode(to: encoder)
      case .consentRevoked(let consentRevoked):
        try consentRevoked.encode(to: encoder)
      }
    }
  }
}
