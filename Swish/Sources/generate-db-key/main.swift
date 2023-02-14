import Sh

try sh(.terminal, #"openssl rand -base64 32"#)
