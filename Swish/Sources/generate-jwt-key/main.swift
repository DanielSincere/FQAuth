import Sh

try sh(.terminal, #"openssl ecparam -name "P-521" -genkey | base64"#)
