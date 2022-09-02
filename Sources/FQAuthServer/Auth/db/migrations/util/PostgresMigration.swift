import FluentPostgresDriver

protocol PostgresMigration: AsyncMigration {
  func prepare(on database: PostgresDatabase) async throws
  func revert(on database: PostgresDatabase) async throws
}

extension PostgresMigration {

  func prepare(on database: Database) async throws {
    try await self.prepare(on: database as! PostgresDatabase)
  }

  func revert(on database: Database) async throws {
    try await self.revert(on: database as! PostgresDatabase)
  }
}
