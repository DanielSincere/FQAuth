import Vapor
import Sh

#if DEBUG
struct LocalDBDestroyCommand: Command {
  
  let help: String = "Destroy local Postgres databases for development and testing"
  
  func run(using context: ConsoleKit.CommandContext, signature: Signature) throws {
    
    try sh(.terminal, #"dropdb --if-exists fqauth_dev"#)
    try sh(.terminal, #"dropdb --if-exists fqauth_test"#)
    
    try sh(.terminal, #"""
      psql \
        --command="DROP USER IF EXISTS fqauth" \
        --command="\du" \
        postgres
      """#)
  }
  
  struct Signature: CommandSignature {
    init() { }
  }
}
#endif
