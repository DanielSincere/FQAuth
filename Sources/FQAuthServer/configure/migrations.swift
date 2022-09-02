import Vapor
import QueuesRedisDriver

extension Application {
  func migrations() throws {
    self.migrations.add(
      CreateMetaMigration(),
      CreateUserMigration(),
      CreateSiwaMigration(),
      CreateRefreshTokenMigration(),
      to: .psql)

    switch self.environment {
    case .testing:
      try self.autoRevert().wait()
      try self.autoMigrate().wait()
    case .development:
      try self.autoMigrate().wait()
    case .production:
      break
    default:
      break
    }
  }
}
