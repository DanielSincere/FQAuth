import FluentPostgresDriver

final class CreateFunctionMigration: PostgresScriptMigration {

  let up = [
    #"CREATE EXTENSION "uuid-ossp";"#,
    #"""
    CREATE FUNCTION updated_at_timestamp()
    RETURNS TRIGGER AS $$
    BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    """#
  ]

  let down = [
    #"DROP EXTENSION IF EXISTS "uuid-ossp""#,
    #"DROP FUNCTION IF EXISTS updated_at_timestamp"#
  ]
}
