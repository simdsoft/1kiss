$install_dir = $args[0]
$buildsrc_dir  = $args[1]

if ((Test-Path $install_dir -PathType Container)) {
    # copy prebuilt luajit manually
    mkdir "$install_dir\include"
    mkdir "$install_dir\lib"
    mkdir "$install_dir\bin"
    mkdir "$install_dir\bin\jit"

    Copy-Item "$buildsrc_dir\src\lua51.lib" "$install_dir\lib\lua51.lib"
    Copy-Item "$buildsrc_dir\src\lua51.dll" "$install_dir\bin\lua51.dll"
    Copy-Item "$buildsrc_dir\src\luajit.exe" "$install_dir\bin\luajit.exe"
    Copy-Item -Path "$buildsrc_dir\src\jit\*.lua" -Destination "$install_dir\bin\jit" -Recurse

    Copy-Item "$buildsrc_dir\src\lauxlib.h" "$install_dir\include\lauxlib.h"
    Copy-Item "$buildsrc_dir\src\lua.h" "$install_dir\include\lua.h"
    Copy-Item "$buildsrc_dir\src\lua.hpp" "$install_dir\include\lua.hpp"
    Copy-Item "$buildsrc_dir\src\luaconf.h" "$install_dir\include\luaconf.h"
    Copy-Item "$buildsrc_dir\src\luajit.h" "$install_dir\include\luajit.h"
    Copy-Item "$buildsrc_dir\src\lualib.h" "$install_dir\include\lualib.h"

    echo "[windows] list ${install_dir}..."
    ls -R "$install_dir"
}
