import Vapor
import Sh

#if DEBUG
struct LocalDBCreateCommand: Command {
  
  let help: String = "Create local Postgres databases for development and testing. Install Postgres using `brew install postgresql`."
  
  func run(using context: ConsoleKit.CommandContext, signature: Signature) throws {
    let createUserScript = #"""
      DO
      $do$
      BEGIN
        IF EXISTS ( SELECT FROM pg_catalog.pg_roles WHERE rolname = 'fqauth') THEN
          RAISE NOTICE 'User "fqauth" already exists. Skipping.';
        ELSE
          CREATE ROLE fqauth LOGIN PASSWORD 'FQAuthServer';
        END IF;
      END
      $do$;
      """#
    
    try sh(.terminal, #"""
      psql \
        --command="$CREATE_USER_SCRIPT" \
        --command="\du" \
        postgres
      """#, environment: ["CREATE_USER_SCRIPT": createUserScript])
    
    try sh(.terminal, #"createdb --owner=fqauth fqauth_test"#)
    try sh(.null, #"psql --username=fqauth --host=localhost fqauth_test -c "select version()""#,
           environment: ["PGPASSWORD": "FQAuthServer"])
    
    try sh(.terminal, #"createdb --owner=fqauth fqauth_dev"#)
    try sh(.null, #"psql --username=fqauth --host=localhost fqauth_dev -c "select version()""#,
           environment: ["PGPASSWORD": "FQAuthServer"])
  }
    
  struct Signature: CommandSignature {
    init() { }
  }
}

#endif
