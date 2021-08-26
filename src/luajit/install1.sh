install_dir=$1
buildsrc_dir=$2

echo "Installing luajit: $buildsrc_dir ===> $install_dir"

# copy prebuilt luajit manually
mkdir "$install_dir/include"
mkdir "$install_dir/lib"

cp "$buildsrc_dir/src/libluajit.a" "$install_dir/lib/libluajit.a"

cp "$buildsrc_dir/src/lauxlib.h" "$install_dir/include/lauxlib.h"
cp "$buildsrc_dir/src/lua.h" "$install_dir/include/lua.h"
cp "$buildsrc_dir/src/lua.hpp" "$install_dir/include/lua.hpp"
cp "$buildsrc_dir/src/luaconf.h" "$install_dir/include/luaconf.h"
cp "$buildsrc_dir/src/luajit.h" "$install_dir/include/luajit.h"
cp "$buildsrc_dir/src/lualib.h" "$install_dir/include/lualib.h"

echo "[unix] list ${install_dir}..."
ls -R "$install_dir"
