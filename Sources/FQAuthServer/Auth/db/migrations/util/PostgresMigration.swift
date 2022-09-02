import FluentPostgresDriver

protocol PostgresMigration: Migration {
  func prepare(on database: PostgresDatabase) -> EventLoopFuture<Void>
  func revert(on database: PostgresDatabase) -> EventLoopFuture<Void>
}

extension PostgresMigration {

  func prepare(on database: Database) -> EventLoopFuture<Void> {
    self.prepare(on: database as! PostgresDatabase)
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    self.revert(on: database as! PostgresDatabase)
  }
}
