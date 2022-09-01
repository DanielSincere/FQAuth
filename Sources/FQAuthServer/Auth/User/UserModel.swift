import Fluent
import FluentPostgresDriver
import Foundation

final class UserModel: Model {
  static let schema = "user"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "first_name")
  var firstName: String

  @Field(key: "last_name")
  var lastName: String

  @Field(key: "created_at")
  var createdAt: Date

  @Field(key: "updated_at")
  var updatedAt: Date

  @Enum(key: "registration_method")
  var registrationMethod: RegistrationMethod

  @Enum(key: "status")
  var status: Status

  @OptionalChild(for: \.$user)
  var siwa: SiwaModel?

  init() { }

  init(
    id: UUID? = nil,
    createdAt: Date = Date(),
    firstName: String,
    lastName: String,
    registrationMethod: RegistrationMethod
  ) {
    self.id = id
    self.createdAt = createdAt
    self.firstName = firstName
    self.lastName = lastName
    self.registrationMethod = registrationMethod
  }

  enum RegistrationMethod: String, Codable, CaseIterable {
    case siwa
  }

  enum Status: String, Codable {
    case active, deactivated
  }
}
