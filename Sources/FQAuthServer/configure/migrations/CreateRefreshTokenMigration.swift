import FluentPostgresDriver

final class CreateRefreshTokenMigration: PostgresScriptMigration {

  let up = [
    #"""
    CREATE TABLE "refresh_token" (
      id uuid PRIMARY KEY DEFAULT uuid_generate_v4 (),
      hashed_token TEXT NOT NULL,
      device_name TEXT NOT NULL,
      expires_at timestamp WITH TIME ZONE NOT NULL,
      created_at timestamp WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
      updated_at timestamp WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
      user_id uuid REFERENCES "user" (id) NOT NULL
    );
    """#,
    #"""
    CREATE TRIGGER refresh_token_updated_at_timestamp
    BEFORE UPDATE ON "refresh_token" FOR EACH ROW
    EXECUTE PROCEDURE updated_at_timestamp();
    """#
  ]

  let down = [
    #"DROP TABLE IF EXISTS "refresh_token""#
  ]
}
