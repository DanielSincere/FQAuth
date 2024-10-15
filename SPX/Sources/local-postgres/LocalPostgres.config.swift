import ShLocalPostgres

extension LocalPostgres {
  static var config: Self = .init(role: "sincereauth",
                                  password: "SincereAuthPassword123",
                                  databaseStem: "sincereauth")
}
