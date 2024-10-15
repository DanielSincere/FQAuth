import Foundation

enum AuthConstant {
  static let refreshTokenLifetime: TimeInterval = .oneDay * 90
  static let accessTokenLifetime: TimeInterval = .oneDay * 30
}

extension TimeInterval {
  static let oneDay: Self = 24 * 60 * 60
}
