import Foundation

public struct AppleStringWrapped<Wrapped: Codable>: Codable {
  
  public let wrapped: Wrapped
  
  public init(from decoder: Decoder) throws {
    let stringContainer = try decoder.singleValueContainer()
    let string = try stringContainer.decode(String.self)    
    let wrapped = try JSONDecoder().decode(Wrapped.self, from: string.data(using: .utf8)!)
    self.wrapped = wrapped
  }
    
  public func encode(to encoder: Encoder) throws {
    let data = try JSONEncoder().encode(wrapped)
    let string = String(data: data, encoding: .utf8)!
    var stringContainer = encoder.singleValueContainer()
    try stringContainer.encode(string)
  }

  public init(wrapped: Wrapped) {
    self.wrapped = wrapped
  }

  public init(string: String) throws {
    let wrapped = try JSONDecoder().decode(Wrapped.self, from: string.data(using: .utf8)!)
    self.wrapped = wrapped
  }
}
