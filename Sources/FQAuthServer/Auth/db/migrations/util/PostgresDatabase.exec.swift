import FluentPostgresDriver

extension PostgresDatabase {

  func exec(_ strings: String...) async throws {
    for i in strings {
      try await self.exec(i)
    }
  }

  func exec(_ string: String) async throws {
    try await self.simpleQuery(string, { _ in }).get()
  }
}
