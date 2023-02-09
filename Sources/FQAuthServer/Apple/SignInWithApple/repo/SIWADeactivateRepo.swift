import Foundation
import Vapor
import SQLKit

struct SIWADeactivateUserRepo {

  func deactivate(siwa: SIWAModel) async throws {
    siwa.encryptedAppleRefreshToken = nil
    siwa.user.status = .deactivated

//    await Self.save(siwa: siwa, db: db)
  }
}
