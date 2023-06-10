$LIB_ROOT = $args[0]

# since 3.1.0, the patch source is identical
# since 3.0.9/3.1.1, the rsa_sup_mul.c was removed
Copy-Item "$PSScriptRoot\rsa_sup_mul.c" "$LIB_ROOT\crypto\bn\rsa_sup_mul.c" -Force
