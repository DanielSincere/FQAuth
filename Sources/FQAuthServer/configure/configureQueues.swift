import Vapor
import Queues

extension Application {

  func configureQueues() {
    guard let redisConfig = self.redis.configuration else {
      fatalError("Configure Redis before configuring Queues")
    }

    self.queues.use(.redis(redisConfig))

    self.queues.schedule(SIWAReadyForReverifyScheduledJob())
      .daily()
      .at(9, 9)

    self.queues.schedule(CleanupExpiredRefreshTokenScheduledJob())
      .daily()
      .at(18, 18)
  }
}
