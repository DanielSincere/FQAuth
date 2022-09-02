import FluentPostgresDriver

final class CreateMetaMigration: PostgresScriptMigration {

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
    #"DROP EXTENSION "uuid-ossp""#,
    #"DROP FUNCTION updated_at_timestamp"#
  ]
}
