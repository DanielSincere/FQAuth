import FluentPostgresDriver

extension PostgresDatabase {

  func exec(_ strings: [String]) -> EventLoopFuture<Void> {
    strings
      .reduce(eventLoop.future()) { partial, nextString in
        partial.flatMap { self.exec(nextString) }
      }
  }

  func exec(_ string: String) -> EventLoopFuture<Void>{
    self.logger.log(level: .trace, .init(stringLiteral: string))
    return self.simpleQuery(string, { _ in })
  }
}
