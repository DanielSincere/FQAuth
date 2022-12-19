import Vapor
import Sh

#if DEBUG
struct LocalDBCreateCommand: Command {
  
  let help: String = "Create local Postgres databases for development and testing. Install Postgres using `brew install postgresql`."
  
  func run(using context: ConsoleKit.CommandContext, signature: Signature) throws {
    try createRole(name: "fqauth", password: "FQAuthServer")

    try createDB(name: "fqauth_test", owner: "fqauth")
    try ensureDBExists(name: "fqauth_test", owner: "fqauth", password: "FQAuthServer")

    try createDB(name: "fqauth_dev", owner: "fqauth")
    try ensureDBExists(name: "fqauth_dev", owner: "fqauth", password: "FQAuthServer")
  }

  private func ensureDBExists(name: String, owner: String, password: String) throws {
    try sh(.null,
      """
      psql \
        --username=\(owner) \
        --host=localhost \(name) \
        -c "select version()"
      """,
           environment: ["PGPASSWORD": password])
  }

  private func createDB(name: String, owner: String) throws {
    try sh(.terminal, "createdb -U postgres --owner=\(owner) \(name)")
  }

  private func createRole(name: String, password: String) throws {
    let createUserScript =
      """
      DO
      $do$
      BEGIN
        IF EXISTS ( SELECT FROM pg_catalog.pg_roles WHERE rolname = '\(name)') THEN
          RAISE NOTICE 'User "\(name)" already exists. Skipping.';
        ELSE
          CREATE ROLE \(name) LOGIN PASSWORD '\(password)';
        END IF;
      END
      $do$;
      """

    try sh(.terminal,
            #"""
            psql \
              -U postgres \
              --command="$CREATE_USER_SCRIPT" \
              --command="\du" \
              postgres
            """#,
           environment: ["CREATE_USER_SCRIPT": createUserScript])
  }

  struct Signature: CommandSignature {
    init() { }
  }
}

#endif
