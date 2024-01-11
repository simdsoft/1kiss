$install_dir = $args[0]
$buildsrc_dir  = $args[1]

$buildout = Join-Path $Global:BUILD_DIR '/'

println "list build output dir ..."
Get-ChildItem $buildout

# copy .lib
$inst_lib_dir = Join-Path $install_dir 'lib/'
mkdirs $inst_lib_dir

if ($Global:is_win_family) {
    # copy includes
    $inst_inc_dir = Join-Path $install_dir 'include'
    mkdirs $inst_inc_dir
    Copy-Item -Path $(Join-Path $buildsrc_dir 'include/*') -Destination $inst_inc_dir -Recurse -Force

    # copy .lib
    Copy-Item "${buildout}libGLESv2.dll.lib" "${inst_lib_dir}libGLESv2.dll.lib" -Force
    Copy-Item "${buildout}libEGL.dll.lib" "${inst_lib_dir}libEGL.dll.lib" -Force

    # copy .dll
    $inst_bin_dir = Join-Path $install_dir 'bin/'
    mkdirs $inst_bin_dir
    Copy-Item "${buildout}libGLESv2.dll" "${inst_bin_dir}libGLESv2.dll" -Force
    Copy-Item "${buildout}libEGL.dll" "${inst_bin_dir}libEGL.dll" -Force

    if (Test-Path "${buildout}d3dcompiler_47.dll" -PathType Leaf) {
        Copy-Item "${buildout}d3dcompiler_47.dll" "${inst_bin_dir}d3dcompiler_47.dll" -Force
    }
} elseif($Global:is_mac) {
    Copy-Item "${buildout}libGLESv2.dylib" "${inst_lib_dir}libGLESv2.dylib" -Force
    Copy-Item "${buildout}libEGL.dylib" "${inst_lib_dir}libEGL.dylib" -Force
} elseif($Global:is_android) {
    Copy-Item "${buildout}libGLESv2_angle.so" "${inst_lib_dir}libGLESv2_angle.so" -Force
    Copy-Item "${buildout}libEGL_angle.so" "${inst_lib_dir}libEGL_angle.so" -Force
} elseif($Global:is_darwin_embed_family) {
    Copy-Item "${buildout}libGLESv2.Framework" "${inst_lib_dir}libGLESv2.Framework" -Recurse -Force
    Copy-Item "${buildout}libEGL.Framework" "${inst_lib_dir}libEGL.Framework" -Recurse -Force
}

println "list install dir ..."
Get-ChildItem -R "$install_dir"
