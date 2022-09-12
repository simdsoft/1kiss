$install_dir = $args[0]
$buildsrc_dir  = $args[1]

if ((Test-Path $install_dir -PathType Container)) {
    # copy prebuilt angle manually
    mkdir "$install_dir\bin"
    Copy-Item "$buildsrc_dir\out\release\libEGL.dll" "$install_dir\bin\libEGL.dll" -Force
    Copy-Item "$buildsrc_dir\out\release\libGLESv2.dll" "$install_dir\bin\libGLESv2.dll" -Force
    Copy-Item "$buildsrc_dir\out\release\d3dcompiler_47.dll" "$install_dir\bin\d3dcompiler_47.dll" -Force

    echo "[windows] list ${install_dir}..."
    ls -R "$install_dir"
}
