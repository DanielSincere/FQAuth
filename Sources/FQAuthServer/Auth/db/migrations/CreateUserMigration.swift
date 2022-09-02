import FluentPostgresDriver

final class CreateUserMigration: PostgresMigration {

  func prepare(on database: PostgresDatabase) -> EventLoopFuture<Void> {
    database.exec(
      #"CREATE TYPE user_registration_method AS ENUM ('siwa')"#,
      #"CREATE TYPE user_status AS ENUM ('active', 'deactivated')"#,

      #"""
      CREATE TABLE "user" (
      id uuid PRIMARY KEY DEFAULT uuid_generate_v4 (),
      first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        status user_status NOT NULL DEFAULT 'active',
        registration_method user_registration_method NOT NULL,
        created_at timestamp WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
        updated_at timestamp WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
      );
      """#,

      #"""
      CREATE TRIGGER user_updated_at_timestamp
      BEFORE UPDATE ON "user" FOR EACH ROW
      EXECUTE PROCEDURE updated_at_timestamp()
      """#
    )
  }

  func revert(on database: PostgresDatabase) -> EventLoopFuture<Void> {
    database.exec(
      #"DROP TABLE "user""#,
      #"DROP TYPE user_status"#,
      #"DROP TYPE user_registration_method"#
    )
  }
}
