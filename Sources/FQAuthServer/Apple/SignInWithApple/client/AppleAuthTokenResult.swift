import Vapor

public enum AppleResponse<D: Decodable> {
  case decoded(D)
  case error(AppleErrorResponse)
}
