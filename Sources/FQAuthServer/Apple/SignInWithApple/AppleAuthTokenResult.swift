enum AppleAuthTokenResult {
  case token(AppleTokenResponse)
  case error(AppleErrorResponse)
}
