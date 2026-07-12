$target_os = $args[0]
$target_cpu = $args[1]
$install_dir = $args[2]

if ($target_os.StartsWith('win')) {
    $pkg = $build_conf.win32_prebuilt
    $repo_base = $build_conf.repo -replace '\.git$', ''
    $tag = "$($build_conf.tag_prefix)$($build_conf.ver)"
    $url = "$repo_base/releases/download/$tag/$pkg"

    $tmp_dir = Join-Path $env:TEMP "dxc_prebuilt"
    $zip_path = Join-Path $tmp_dir $pkg
    mkdirs $tmp_dir

    if (!(Test-Path $zip_path)) {
        Write-Output "Downloading $url ..."
        Invoke-WebRequest -Uri $url -OutFile $zip_path
    }
    Expand-Archive -Path $zip_path -DestinationPath $tmp_dir -Force

    $arch_dir = if ($target_cpu -eq 'x64') { 'x64' } else { $target_cpu }
    $bin_dir = Join-Path $install_dir "bin"
    $lib_dir = Join-Path $install_dir "lib"
    mkdirs $bin_dir
    mkdirs $lib_dir
    Copy-Item (Join-Path $tmp_dir "bin/$arch_dir/dxcompiler.dll") $bin_dir -Force
    Copy-Item (Join-Path $tmp_dir "bin/$arch_dir/dxil.dll") $bin_dir -Force
    Copy-Item (Join-Path $tmp_dir "lib/$arch_dir/dxcompiler.lib") $lib_dir -Force
    Copy-Item (Join-Path $tmp_dir "lib/$arch_dir/dxil.lib") $lib_dir -Force
    $inc_src = Join-Path $tmp_dir "inc"
    if (Test-Path $inc_src) {
        Copy-Item $inc_src (Join-Path $install_dir "include") -Recurse -Force
    }
} else {
    $build_dir = Join-Path $lib_src "build"
    mkdirs $build_dir

    $config_opts = @() + $build_conf.options
    $config_opts += "-DCMAKE_INSTALL_PREFIX=$install_dir"

    if ($target_os -eq 'osx') {
        $arch = if ($target_cpu -eq 'x64') { 'x86_64' } else { $target_cpu }
        $config_opts += "-DCMAKE_OSX_ARCHITECTURES=$arch"
    }

    cmake -S $lib_src -B $build_dir @config_opts
    cmake --build $build_dir --target dxcompiler
    cmake --install $build_dir --component dxcompiler --prefix $install_dir
}
