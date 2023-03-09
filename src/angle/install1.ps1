$install_dir = $args[0]
$buildsrc_dir  = $args[1]

# copy includes
if (!(Test-Path "$install_dir\include" -PathType Container)) {
    mkdir "$install_dir\include"
}

Copy-Item -Path "$buildsrc_dir\include\*" -Destination "$install_dir\include" -Recurse -Force

# copy .lib
if (!(Test-Path "$install_dir\lib" -PathType Container)) {
    mkdir "$install_dir\lib"
}

Copy-Item "$buildsrc_dir\out\release\libGLESv2.dll.lib" "$install_dir\lib\libGLESv2.dll.lib" -Force
Copy-Item "$buildsrc_dir\out\release\libEGL.dll.lib" "$install_dir\lib\libEGL.dll.lib" -Force

# copy .dll
if (!(Test-Path "$install_dir\bin" -PathType Container)) {
    mkdir "$install_dir\bin"
}
Copy-Item "$buildsrc_dir\out\release\libGLESv2.dll" "$install_dir\bin\libGLESv2.dll" -Force
Copy-Item "$buildsrc_dir\out\release\libEGL.dll" "$install_dir\bin\libEGL.dll" -Force

if (Test-Path "$buildsrc_dir\out\release\d3dcompiler_47.dll" -PathType Leaf) {
    Copy-Item "$buildsrc_dir\out\release\d3dcompiler_47.dll" "$install_dir\bin\d3dcompiler_47.dll" -Force
}

Write-Output "[windows] list ${install_dir}..."
Get-ChildItem -R "$install_dir"
