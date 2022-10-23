import Fluent
import FluentPostgresDriver
import Crypto
import Foundation

final class RefreshTokenModel: Model {
  static let schema = "refresh_token"

  @ID(key: .id)
  var id: UUID?

  @Parent(key: "user_id")
  var user: UserModel

  // Displayed to user so they can recognize a token
  @Field(key: "device_name")
  var deviceName: String

  @Field(key: "hashed_token")
  var hashedToken: String

  @Field(key: "created_at")
  var createdAt: Date

  @Field(key: "expires_at")
  var expiresAt: Date

  init() { }

  init(id: UUID? = nil, userId: UserModel.IDValue, deviceName: String, token: String, createdAt: Date = Date(), expiresAt: Date? = nil) {
    self.id = id
    self.$user.id = userId
    self.deviceName = deviceName
    self.hashedToken = Self.hash(string: token)
    self.createdAt = createdAt
    self.expiresAt = expiresAt ?? Date(timeInterval: AuthConstant.refreshTokenLifetime, since: createdAt)
  }

  static func findBy(token: String, db: Database) -> EventLoopFuture<RefreshTokenModel?> {
    RefreshTokenModel
      .query(on: db)
      .filter(\.$hashedToken == Self.hash(string: token))
      .filter(\.$expiresAt > Date())
      .first()
  }
  
  static func listBy(userID: UserModel.IDValue, db: Database) -> EventLoopFuture<[RefreshTokenModel]> {
    RefreshTokenModel
      .query(on: db)
      .filter(\.$user.$id == userID)
      .all()
  }

  private static func hash(string: String) -> String {
    SHA512.hash(data: string.data(using: .utf8)!)
      .hexEncodedString(uppercase: true)
  }
}
