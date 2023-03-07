$LIB_ROOT = $args[0]

Copy-Item "$PSScriptRoot\rsa_sup_mul.c" "$LIB_ROOT\crypto\bn\rsa_sup_mul.c" -Force
