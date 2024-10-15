import FluentPostgresDriver

protocol PostgresScriptMigration: PostgresMigration {
  var up: [String] { get }
  var down: [String] { get }
}

extension PostgresScriptMigration {
  func prepare(on database: PostgresDatabase) -> EventLoopFuture<Void> {
    database.exec(up)
  }

  func revert(on database: PostgresDatabase) -> EventLoopFuture<Void> {
    database.exec(down)
  }
}
