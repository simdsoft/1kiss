$install_dir = $args[0]
$lib_name = "dxcompiler"

if ($IsWin) {
    $bin_dir = Join-Path $install_dir "bin"
    $lib_dir = Join-Path $install_dir "lib"
    mkdirs $bin_dir
    mkdirs $lib_dir
    $dll = Join-Path $BUILD_DIR "Release/bin/${lib_name}.dll"
    $lib = Join-Path $BUILD_DIR "Release/lib/${lib_name}.lib"
    if (Test-Path $dll) { Copy-Item $dll $bin_dir }
    if (Test-Path $lib) { Copy-Item $lib $lib_dir }
} else {
    $dest_dir = Join-Path $install_dir "lib"
    mkdirs $dest_dir
    if ($IsLinux) {
        $so = Join-Path $BUILD_DIR "lib/lib${lib_name}.so"
        if (Test-Path $so) { Copy-Item $so $dest_dir }
    } elseif ($IsMacOS) {
        $dylib = Join-Path $BUILD_DIR "Release/lib/lib${lib_name}.dylib"
        if (!(Test-Path $dylib)) {
            $dylib = Join-Path $BUILD_DIR "lib/lib${lib_name}.dylib"
        }
        if (Test-Path $dylib) { Copy-Item $dylib $dest_dir }
    }
}
