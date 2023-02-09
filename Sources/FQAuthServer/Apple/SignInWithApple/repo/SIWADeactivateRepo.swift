import Foundation
import Vapor
import SQLKit

struct SIWADeactivateUserRepo {

  let database: SQLDatabase

  init(application: Application) {
    let db = application.db(.psql)
    self.database = db as! SQLDatabase
  }

  init(database: SQLDatabase) {
    self.database = database
  }

  func deactivate(siwaID: SIWAModel.IDValue) async throws {
    let sql =
    """
    WITH user_id AS (
      UPDATE siwa
      SET encrypted_apple_refresh_token = NULL
      WHERE id = $1
      RETURNING user_id
    )
    UPDATE "user"
    SET status = 'deactivated'
    WHERE id = (SELECT user_id FROM user_id)
    """
    try await self.database.execute(sql: SQLRaw(sql, [siwaID])) { _ in }
  }
}
