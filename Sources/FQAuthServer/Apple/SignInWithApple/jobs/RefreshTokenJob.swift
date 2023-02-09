import Foundation
import JWTKit
import Queues
import FluentPostgresDriver

struct RefreshTokenJob: AsyncJob {
  typealias Payload = SIWAModel.IDValue

  func dequeue(_ context: Queues.QueueContext, _ payload: SIWAModel.IDValue) async throws {

    let client = LiveSIWAClient(application: context.application)
    let db = context.application.db(.psql)
    try await Self.refreshTokenWithApple(siwaID: payload,
                                         logger: context.logger,
                                         db: db,
                                         client: client,
                                         signers: context.application.jwt.signers)
  }

  static func refreshTokenWithApple(now: Date = Date(),
                                    siwaID: SIWAModel.IDValue,
                                    logger: Logger,
                                    db: Database,
                                    client: SIWAClient,
                                    signers: JWTVerifying) async throws {

    guard let siwa = try await SIWAModel.findBy(id: siwaID, db: db).get() else {
      logger.debug("couldn't find a SIWAModel with id")
      return
    }

    siwa.attemptedRefreshAt = now
    try await siwa.save(on: db)

    guard let refreshToken = siwa.unsealedAppleRefreshToken() else {
      logger.debug("no refresh token for a SIWAModel with id")
      return
    }

    let tokenResult = try await client.validateRefreshToken(token: refreshToken).get()

    switch tokenResult {
    case .decoded(let success):
      do {
        let _: AppleIdentityToken = try signers.verify(success.id_token, as: AppleIdentityToken.self)
      } catch {
        logger.error("\(error.localizedDescription)")

        siwa.attemptedRefreshResult = .failure

        return
      }

      siwa.attemptedRefreshResult = .success
      await Self.save(siwa: siwa, db: db)

    case .error(let error):

      siwa.attemptedRefreshResult = .failure
      switch error.errorCode {
      case .invalid_grant:
        await Self.deauthorizeUser(siwa: siwa, db: db)
      case .invalid_client, .invalid_request, .invalid_scope, .unauthorized_client, .unsupported_grant_type, .none:
        siwa.attemptedRefreshResult = .failure
        await Self.save(siwa: siwa, db: db)
      }
    }
  }

  static func save(siwa: SIWAModel, db: Database) async {
    do {
      try await siwa.save(on: db)
    } catch {
      db.logger.error("Couldn't save siwa: \(error.localizedDescription)")
    }
  }

  static func deauthorizeUser(siwa: SIWAModel, db: Database) async {
    siwa.encryptedAppleRefreshToken = nil
//    siwa.user.status = .deactivated

    await Self.save(siwa: siwa, db: db)
  }
}
