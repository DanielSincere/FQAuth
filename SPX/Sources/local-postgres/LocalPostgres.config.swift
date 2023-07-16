import ShLocalPostgres

extension LocalPostgres {
  static var config: Self = .init(role: "fqauth",
                                  password: "FQAuthPassword123",
                                  databaseStem: "fqauth")
}
