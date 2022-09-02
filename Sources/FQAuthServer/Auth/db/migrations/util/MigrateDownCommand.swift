import Vapor
import FluentPostgresDriver

struct MigrateDownCommand: AnyCommand {
  let application: Application
  let help: String = "Run all `down` commands"

  func run(using context: inout CommandContext) throws {
    let db = (application.db(.psql) as! PostgresDatabase)
    let downs = AllMigrations.allCases.reversed()
      .reduce([String]()) { partialResult, m in
        partialResult + m.migration.down
      }
    try db.exec(downs).wait()

    try db.exec("DROP TABLE IF EXISTS _fluent_migrations").wait()
  }
}
