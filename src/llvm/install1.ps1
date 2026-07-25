$install_dir = $args[0]

$artifact_files = @(
    @('Release\bin\libclang.dll', 'Release\bin\clang-format.exe'),
    @('lib/libclang.so', 'bin/clang-format'),
    @('Release/lib/libclang.dylib', 'Release/bin/clang-format')
)[$HOST_OS_INT]

foreach($path in $artifact_files) {
    $full_path = Join-Path $BUILD_DIR $path
    if (Test-Path $full_path -PathType Leaf) {
        $ext = [System.IO.Path]::GetExtension($path)
        if ($ext -in '.dll', '.exe') {
            $sub_dir = 'bin'
        } elseif ($ext -in '.dylib', '.so') {
            $sub_dir = 'lib'
        } else {
            $sub_dir = 'bin'
        }
        $install_dest = Join-Path $install_dir $sub_dir
        mkdirs $install_dest
        Write-Host "Copying $full_path to $install_dest"
        Copy-Item $full_path $install_dest
    } else {
        Write-Warning "The file $full_path not exist"
    }
}
