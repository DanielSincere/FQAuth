import Vapor
import QueuesRedisDriver

extension Application {

  func configureMigrations() throws {
    for i in AllMigrations.allCases {
      self.migrations.add(i.migration, to: .psql)
    }
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
