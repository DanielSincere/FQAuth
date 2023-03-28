import ArgumentParser
import ShLocalPostgres

struct Create: ParsableCommand {
  func run() throws {
    try LocalPostgres.config.createAll()
  }
}
