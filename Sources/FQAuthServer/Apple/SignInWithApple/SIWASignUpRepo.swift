import Foundation
import Vapor
import SQLKit

struct SIWASignUpRepo {

  struct Params {
    let email: String
    let firstName: String
    let lastName: String
    let deviceName: String
    let registrationMethod: UserModel.RegistrationMethod
    let appleUserId: String
    let appleRefreshToken: String
  }

  let logger: Logger
  let eventLoop: EventLoop
  let database: SQLDatabase

  init(request: Request) {
    self.logger = request.logger
    self.eventLoop = request.eventLoop
    self.database = request.db as! SQLDatabase
  }

  init(application: Application) {
    self.logger = application.logger
    let db = application.db(.psql)
    self.database = db as! SQLDatabase
    self.eventLoop = db.eventLoop
  }

  init(logger: Logger, eventLoop: EventLoop, database: SQLDatabase) {
    self.logger = logger
    self.eventLoop = eventLoop
    self.database = database
  }

  func signUp(_ params: Params) -> EventLoopFuture<UserModel.IDValue> {

    let sqlTemplate = """
        WITH new_user as (
          INSERT INTO "user" (first_name, last_name, registration_method)
          VALUES ($1, $2, $3::user_registration_method)
          RETURNING id AS user_id
        )
        INSERT INTO "siwa" (email, apple_user_id, encrypted_apple_refresh_token, user_id)
        VALUES ($4,$5,$6,(SELECT user_id FROM new_user))
        RETURNING user_id AS user_id;
        """

    let binds: [String] =  [
      params.firstName,
      params.lastName,
      params.registrationMethod.rawValue,
      params.email,
      params.appleUserId,
      DBSeal().seal(string: params.appleRefreshToken)
    ]

    let sql = SQLRaw(sqlTemplate, binds)

    var userIdResult: Result<UUID, Error>? = nil

    let insert = self.database.execute(sql: sql) { row in
      userIdResult = Result { try row.decode(column: "user_id", inferringAs: UUID.self) }
    }

    return insert.flatMap { _ in
      switch userIdResult {
      case .success(let userId):
        return self.eventLoop.makeSucceededFuture(userId)
      case .failure(let error):
        return self.eventLoop.makeFailedFuture(error)
      case .none:
        self.logger.critical("user id not generated")
        return self.eventLoop.makeFailedFuture(Abort(.forbidden,
                                                        headers: HTTPHeaders(),
                                                        reason: "internal server error",
                                                        identifier: "internal server error",
                                                        suggestedFixes: ["Try again"]))
      }
    }
  }
}
