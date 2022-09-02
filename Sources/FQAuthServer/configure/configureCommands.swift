import Vapor
import PostgresNIO

extension Application {

  func configureCommands() {
    self.commands.use(MigrateDownCommand(application: self), as: "migrate-down")
  }
}
