import Vapor

extension Application {

  func resetDatabase() throws {
    try self.autoRevert().wait()
    try self.autoMigrate().wait()
  }
}
