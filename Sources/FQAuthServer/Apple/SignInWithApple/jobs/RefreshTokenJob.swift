import Foundation
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
                                         client: client)
  }

  static func refreshTokenWithApple(siwaID: SIWAModel.IDValue,
                                    logger: Logger,
                                    db: Database,
                                    client: SIWAClient) async throws {

    guard let siwa = try await SIWAModel.findBy(id: siwaID, db: db).get() else {
      logger.debug("couldn't find a SIWAModel with id")
      return
    }

    guard let refreshToken = siwa.unsealedAppleRefreshToken() else {
      logger.debug("no refresh token for a SIWAModel with id")
      return
    }

    let tokenResult = try await client.validateRefreshToken(token: refreshToken).get()
  }
}
