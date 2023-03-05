import Vapor
@testable import FQAuthServer
import Fluent

extension Application {

  func resetDatabase() throws {
    //    try self.autoRevert().wait()
    try self.autoMigrate().wait()
    
    let models: [any Model.Type] = [
      RefreshTokenModel.self,
      SIWAModel.self,
      UserModel.self,
    ]
    
    for model in models {
      try model.deleteAll(on: self.db(.psql)).wait()
    }
  }
}

private extension Model {
  static func deleteAll(on db: Database) -> EventLoopFuture<Void> {
    Self.query(on: db)
      .all()
      .flatMap { $0.delete(on: db) }
  }
}
