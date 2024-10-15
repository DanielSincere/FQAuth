import FluentPostgresDriver

final class AddRolesToUserMigration: PostgresScriptMigration {
  let up = [
    #"ALTER TABLE "user" ADD COLUMN roles text[]"#
  ]

  let down = [
    #"ALTER TABLE "user" DROP COLUMN roles"#
  ]
}
