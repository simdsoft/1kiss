$install_dir = $args[0]
# $libsrc_dir  = $args[1]

$artifact_path = @('Release\bin\libclang.dll', 'lib\libclang.so', 'Release\lib\libclang.dylib')[$HOST_OS]
$install_dest = (Join-Path $install_dir (@('lib', 'bin')[$IsWin]))
mkdirs $install_dest
Copy-Item (Join-Path $BUILD_DIR "$artifact_path") $install_dest