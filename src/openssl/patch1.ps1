$LIB_ROOT = $args[0]

# since 3.1.0, the patch source is identical
Copy-Item "$PSScriptRoot\rsa_sup_mul.c" "$LIB_ROOT\crypto\bn\rsa_sup_mul.c" -Force
