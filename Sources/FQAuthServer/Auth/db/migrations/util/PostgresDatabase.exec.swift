import FluentPostgresDriver

extension PostgresDatabase {

  func exec(_ strings: [String]) -> EventLoopFuture<Void> {
    strings
      .map { string in
        self.exec(string)
      }
      .reduce(eventLoop.future()) { partial, next in
        partial.flatMap { next }
      }
  }

  func exec(_ string: String) -> EventLoopFuture<Void>{
    self.logger.log(level: .trace, .init(stringLiteral: string))
    return self.simpleQuery(string, { _ in })
  }
}
