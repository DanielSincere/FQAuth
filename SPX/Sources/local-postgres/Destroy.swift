import ArgumentParser
import ShLocalPostgres

struct Destroy: ParsableCommand {
  func run() throws {
    try LocalPostgres.config.destroyAll()
  }
}
