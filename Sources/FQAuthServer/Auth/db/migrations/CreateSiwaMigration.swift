import FluentPostgresDriver

final class CreateSiwaMigration: PostgresScriptMigration {

  let up = [
    #"""
    CREATE TYPE siwa_attempted_refresh_result AS ENUM (
      'initial',
      'success',
      'failure');
    """#,
    #"""
    CREATE TABLE "siwa" (
      id uuid PRIMARY KEY DEFAULT uuid_generate_v4 (),
      email TEXT,
      apple_user_id TEXT NOT NULL,
      encrypted_apple_refresh_token TEXT,
      attempted_refresh_result siwa_attempted_refresh_result NOT NULL DEFAULT 'initial',
      attempted_refresh_at timestamp WITH TIME ZONE,
      created_at timestamp WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
      updated_at timestamp WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
      user_id uuid REFERENCES "user" (id) NOT NULL
    );
    """#,
    #"""
    CREATE TRIGGER siwa_updated_at_timestamp
    BEFORE UPDATE ON "siwa" FOR EACH ROW
    EXECUTE PROCEDURE updated_at_timestamp();
    """#,
    #"""
    CREATE UNIQUE INDEX apple_user_id_unique_idx on "siwa" (apple_user_id);
    """#
  ]
  let down = [
    #"DROP TABLE IF EXISTS "siwa""#,
    #"DROP TYPE IF EXISTS siwa_attempted_refresh_result"#
  ]
}
