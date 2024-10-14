import Foundation

public enum AppleSingleOrArray<Element: Codable>: Codable {
  case single(Element)
  case array([Element])
  
  public init(from decoder: Decoder) throws {
    if let single = Self.decodeSingle(from: decoder) {
      self = .single(single)
    } else if let array = Self.decodeArray(from: decoder) {
      self = .array(array)
    } else {
      throw Nope()
    }
  }
  
  public var single: Element? {
    switch self {
    case .single(let element):
      return element
    case .array:
      return nil
    }
  }
  
  public var array: [Element]? {
    switch self {
    case .single:
      return nil
    case .array(let array):
      return array
    }
  }
    
  public func encode(to encoder: Encoder) throws {
    switch self {
    case .array(let array):
      var container = encoder.unkeyedContainer()
      try container.encode(array)
    case .single(let single):
      var container = encoder.singleValueContainer()
      try container.encode(single)
    }
  }
  
  static func decodeSingle(from decoder: Decoder) -> Element? {
    do {
      let container = try decoder.singleValueContainer()
      return try container.decode(Element.self)
    } catch {
      return nil
    }
  }
  
  static func decodeArray(from decoder: Decoder) -> [Element]? {
    do {
      var container = try decoder.unkeyedContainer()
      return try container.decode([Element].self)
    } catch {
      return nil
    }
  }
  
  struct Nope: Error { }
}
