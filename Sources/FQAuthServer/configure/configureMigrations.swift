import Vapor
import QueuesRedisDriver

extension Application {

  func configureMigrations() throws {

      self.migrations.add(CreateFunctionMigration(),
                          CreateUserMigration(),
                          CreateSiwaMigration(),
                          CreateRefreshTokenMigration(),
                          AddRolesToUserMigration(),
                          to: .psql)
  }
}
