import Foundation

public enum AppleJsonBool: String, Codable {
  case `true`, `false`

  public var value: Bool {
    switch self {
    case .true:
      return true
    case .false:
      return false
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    do {
      let bool = try container.decode(Bool.self)
      self = bool ? .true : .false
    } catch {
      let string = try container.decode(String.self)
      guard let parsed = Self.init(rawValue: string) else {
        throw ParseError(string: string)
      }
      self = parsed
    }
  }

  public struct ParseError: Error {
    public let string: String
  }
}
