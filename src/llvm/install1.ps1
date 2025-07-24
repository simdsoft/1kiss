$install_dir = $args[0]

$artifact_files = @(@('Release\bin\libclang.dll', 'Release\bin\clang-format.exe'), 'lib\libclang.so', 'Release\lib\libclang.dylib')[$HOST_OS_INT]
$install_dest = (Join-Path $install_dir (@('lib', 'bin')[$IsWin]))
mkdirs $install_dest

foreach($path in $artifact_files) {
    $full_path = (Join-Path $BUILD_DIR "$path")
    if (Test-Path $full_path -PathType Leaf) {
        Write-Host "Copying $full_path to $install_dest"
        Copy-Item $full_path $install_dest
    } else {
        Write-Warning "The file $full_path not exist"
    }
}
