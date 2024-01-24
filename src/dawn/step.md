## Checkout

can share angle depot_tools

```sh
# Clone the repo as "dawn"
git clone https://dawn.googlesource.com/dawn dawn && cd dawn

# Bootstrap the gclient configuration
cp scripts/standalone.gclient .gclient

# windows
$env:DEPOT_TOOLS_WIN_TOOLCHAIN=0

# Fetch external dependencies and toolchains with gclient
gclient sync
```

##  gn with ninja

```sh
mkdir -p out/Debug
# for vs2022 sln: gn gen out/Debug --ide=vs2022 --sln=dawn-debug
gn gen out/Debug
autoninja -C out/Debug
```

## cmake with ninja

```sh
mkdir -p out/Debug
cd out/Debug
cmake -GNinja ../..
ninja # or autoninja
```

