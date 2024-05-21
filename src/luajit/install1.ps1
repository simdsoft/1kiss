$install_dir = $args[0]
$libsrc_dir  = $args[1]

if ($IsWindows) {
    # copy prebuilt luajit manually
    mkdir "$install_dir\include" -Force
    mkdir "$install_dir\lib" -Force
    mkdir "$install_dir\bin" -Force
    mkdir "$install_dir\bin\jit" -Force

    Copy-Item "$libsrc_dir\src\lua51.lib" "$install_dir\lib\lua51.lib" -Force
    Copy-Item "$libsrc_dir\src\lua51.dll" "$install_dir\bin\lua51.dll" -Force
    Copy-Item "$libsrc_dir\src\luajit.exe" "$install_dir\bin\luajit.exe" -Force
    Copy-Item -Path "$libsrc_dir\src\jit\*.lua" -Destination "$install_dir\bin\jit" -Recurse -Force

    Copy-Item "$libsrc_dir\src\lauxlib.h" "$install_dir\include\lauxlib.h" -Force
    Copy-Item "$libsrc_dir\src\lua.h" "$install_dir\include\lua.h" -Force
    Copy-Item "$libsrc_dir\src\lua.hpp" "$install_dir\include\lua.hpp" -Force
    Copy-Item "$libsrc_dir\src\luaconf.h" "$install_dir\include\luaconf.h" -Force
    Copy-Item "$libsrc_dir\src\luajit.h" "$install_dir\include\luajit.h" -Force
    Copy-Item "$libsrc_dir\src\lualib.h" "$install_dir\include\lualib.h" -Force

    echo "[windows] list ${install_dir}..."
    ls -R "$install_dir"
} else {
    # copy prebuilt luajit manually
    mkdir "$install_dir/include"
    mkdir "$install_dir/lib"

    cp "$libsrc_dir/src/libluajit.a" "$install_dir/lib/libluajit.a"

    cp "$libsrc_dir/src/lauxlib.h" "$install_dir/include/lauxlib.h"
    cp "$libsrc_dir/src/lua.h" "$install_dir/include/lua.h"
    cp "$libsrc_dir/src/lua.hpp" "$install_dir/include/lua.hpp"
    cp "$libsrc_dir/src/luaconf.h" "$install_dir/include/luaconf.h"
    cp "$libsrc_dir/src/luajit.h" "$install_dir/include/luajit.h"
    cp "$libsrc_dir/src/lualib.h" "$install_dir/include/lualib.h"

    echo "[unix] list ${install_dir}..."
}
