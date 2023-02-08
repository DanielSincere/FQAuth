import Vapor

public enum AppleAuthTokenResult {
  case token(AppleTokenResponse)
  case error(AppleErrorResponse)
}

public enum AppleAuthTokenRefreshResult {
  case token(AppleTokenRefreshResponse)
  case error(AppleErrorResponse)
}
