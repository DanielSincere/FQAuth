import FluentPostgresDriver

extension PostgresDatabase {

  func exec(_ strings: [String]) -> EventLoopFuture<Void> {
    return strings
       .map { string in
         self.exec(string)
       }
       .sequencedFlatMapEach(on: self.eventLoop) { element in
         element
       }
  }

  func exec(_ strings: String...) -> EventLoopFuture<Void> {
    self.exec(strings)
  }

  func exec(_ string: String) -> EventLoopFuture<Void>{
    self.simpleQuery(string, { _ in })
  }
}
