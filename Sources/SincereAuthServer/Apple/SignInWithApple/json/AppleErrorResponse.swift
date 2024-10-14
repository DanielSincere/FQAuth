import Vapor

public struct AppleErrorResponse: Codable, Content, Error, LocalizedError {
  public let error: String

  public var errorCode: ErrorCode? {
    .init(rawValue: error)
  }

  public enum ErrorCode: String {
    case invalid_request
    case invalid_client
    case invalid_grant
    case unauthorized_client
    case unsupported_grant_type
    case invalid_scope
  }

  public var errorDescription: String? {
    "Verification with Apple failed: \(error)"
  }
}
