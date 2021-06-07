$ARCH = $args[0]

$buildware_root=(Resolve-Path .\).Path
$build_script = "$buildware_root\1k\build.ps1"
$INSTALL_ROOT="install_windows_${ARCH}"

Invoke-Expression -Command "$build_script jpeg-turbo $ARCH $INSTALL_ROOT"
Invoke-Expression -Command "$build_script openssl $ARCH $INSTALL_ROOT"

# Export INSTALL_ROOT for uploading
Write-Output "INSTALL_ROOT=$INSTALL_ROOT" >> ${env:GITHUB_ENV}
