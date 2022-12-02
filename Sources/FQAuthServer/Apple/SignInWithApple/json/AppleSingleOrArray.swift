import Foundation

public enum AppleSingleOrArray<Element: Decodable>: Decodable {
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
