import Vapor
import Queues

extension Application {

  func configureQueues() throws {
    guard let redisConfig = self.redis.configuration else {
      fatalError("Configure Redis before configuring Queues")
    }

    self.queues.use(.redis(redisConfig))

    self.queues.add(ConsentRevokedJob())
    self.queues.add(EmailEnabledJob())
    self.queues.add(EmailDisabledJob())
    self.queues.add(SIWAAccountDeletedJob())
    self.queues.add(RefreshTokenJob())

    self.queues.schedule(SIWAReadyForReverifyScheduledJob())
      .daily()
      .at(9, 9)

    self.queues.schedule(CleanupExpiredRefreshTokenScheduledJob())
      .daily()
      .at(18, 18)

    if Environment.get("RUN_SCHEDULED_QUEUES_IN_MAIN_PROCESS") == "YES" {
      try self.queues.startScheduledJobs()
    }

    if Environment.get("RUN_QUEUES_IN_MAIN_PROCESS") == "YES" {
      try self.queues.startInProcessJobs()
    }
  }
}
