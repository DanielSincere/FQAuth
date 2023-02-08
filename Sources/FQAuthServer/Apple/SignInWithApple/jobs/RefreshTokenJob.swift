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
                                    signers: JWTSigners) async throws {

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
        let _: AppleIdentityToken = try signers.verify(success.id_token)
      } catch {
        await Self.deauthorizeUser(siwa: siwa)
        return
      }

      siwa.attemptedRefreshResult = .success
      do {
        try await siwa.save(on: db)
      } catch {
        logger.error("\(error.localizedDescription)")
      }

    case .error(let error):
      logger.error("\(error.localizedDescription)")
      await Self.deauthorizeUser(siwa: siwa)
    }
  }

  static func deauthorizeUser(siwa: SIWAModel) async {

  }
}
