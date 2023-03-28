import ShLocalPostgres
import ArgumentParser

@main
struct LocalPostgresCommand: ParsableCommand {

  static var configuration = CommandConfiguration(
      abstract: "Create or destroy a local postgres database.",
      subcommands: [Create.self, Destroy.self])
}
