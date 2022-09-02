import Vapor
import QueuesRedisDriver

extension Application {

  func configureMigrations() throws {

      self.migrations.add(CreateFunctionMigration(),
                          CreateUserMigration(),
                          CreateSiwaMigration(),
                          CreateRefreshTokenMigration(),
                          to: .psql)

//    switch self.environment {
//    case .testing:
//      try self.autoRevert().wait()
//      try self.autoMigrate().wait()
//    case .development:
//      break
//    case .production:
//      break
//    default:
//      break
//    }
  }
}
