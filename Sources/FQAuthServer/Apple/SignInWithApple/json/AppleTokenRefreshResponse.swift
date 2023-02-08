import Vapor

public struct AppleTokenRefreshResponse: Codable, Content {

  /// A token used to access allowed data, such as generating and
  /// exchanging transfer identifiers during user migration. For
  /// more information, see Transferring Your Apps and Users to
  /// Another Team and Bringing New Apps and Users into Your Team.
  public let access_token: String

  /// The amount of time, in seconds, before the access token expires.
  public let expires_in: TimeInterval

  /// A JSON Web Token (JWT) that contains the user’s identity
  /// information.
  public let id_token: String

  /// The refresh token used to regenerate new access tokens
  /// when validating an authorization code. Store this token
  /// securely on your server. The refresh token isn’t returned
  /// when validating an existing refresh token.
//  public let refresh_token: String

  /// The type of access token, which is always bearer.
  public let token_type: String
}
