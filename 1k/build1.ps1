#
# Copyright (c) 2021-2022 Bytedance Inc.
#
# params: LIB_NAME BUILD_ARCH INSTALL_ROOT

$LIB_NAME = $args[0]
$BUILD_ARCH = $args[1]
$INSTALL_ROOT = $args[2]

$BUILDWARE_ROOT=(Resolve-Path .\).Path

$PROPS_FILE="src\${LIB_NAME}\build.yml"
if(!(Test-Path $PROPS_FILE -PathType Leaf)) {
    Write-Output "repo config for lib ${LIB_NAME} not exists!"
    return -1
}

# Parse openssl checkout tag, such as OpenSSL_1_1_1k
$PROPS = ConvertFrom-Yaml -Yaml (Get-Content $PROPS_FILE -raw)
$repo = $PROPS.'repo'
$ver = $PROPS.'ver'
$tag_prefix = $PROPS.'tag_prefix'
$tag_dot2ul = $PROPS.'tag_dot2ul'
$config_options_msw=$PROPS.'config_options_msw'
$cb_script = $PROPS.'cb_script'
$cb_tool = $PROPS.'cb_tool'
# $cmake_target = $PROPS.'cmake_target'
$cb_dir = $PROPS.'cb_dir'

if($tag_dot2ul -eq 'true') {
    $ver = ([Regex]::Replace($ver, '\.', '_'))
}
$release_tag="${tag_prefix}${ver}"

Write-Output $config_options_msw
$CONFIG_OPTIONS=($config_options_msw -split ' ')

# CONFIG_ALL_OPTIONS
$CONFIG_ALL_OPTIONS=@()

# Determine build target & config options
if ($cb_tool -eq 'cmake') {
    if($BUILD_ARCH -eq "x86") {
        $CONFIG_ALL_OPTIONS += '-A', 'Win32'
    }
    # only support vs2019+, default is Win64
}
elseif ($cb_tool -eq 'perl') { # opnel openssl use perl
    if($BUILD_ARCH -eq "x86") {
        $CONFIG_ALL_OPTIONS += 'VC-WIN32'
    }
    else {
        $CONFIG_ALL_OPTIONS += 'VC-WIN64A'
    }
}

$CONFIG_ALL_OPTIONS += $CONFIG_OPTIONS

$BUILD_SRC="buildsrc_$BUILD_ARCH"

Set-Location $BUILD_SRC

# Determin lib src root dir
$LIB_SRC = ''
if ($repo.EndsWith('.git')) {
    $LIB_SRC = $LIB_NAME
}
else {
    $LIB_SRC = (Split-Path $repo -leafbase)
    if ($LIB_SRC.EndsWith('.tar')) {
        $LIB_SRC = $LIB_SRC.Substring(0, $LIB_SRC.length - 4)
    }
}

# Checking out...
if(!(Test-Path $LIB_SRC -PathType Container)) {
    if ($repo.EndsWith('.git')) {
        Write-Output "Checking out $repo, please wait..."
        git clone -q $repo $LIB_NAME
        Set-Location $LIB_SRC
        git checkout $release_tag
    }
    else {
       if ($repo.EndsWith('.tar.gz')) {
            $outputFile="${LIB_SRC}.tar.gz"
       }
       else {
            $outputFile="${LIB_SRC}.zip"
       }
       Write-Output "Downloading $repo ---> $outputFile"
       Invoke-WebRequest $repo -o .\$outputFile
       if ($repo.EndsWith('.tar.gz')) {
            tar -xvzf .\$outputFile
       } else {
            Expand-Archive -Path $outputFile -DestinationPath .\
       }

       Write-Output "Entering $LIB_SRC ..."
       Set-Location $LIB_SRC
    }
}
else {
    Write-Output "Entering $LIB_SRC ..."
    Set-Location $LIB_SRC
}

# Prepare source when use google gn build system
if ($cb_tool -eq 'gn') {
    # download depot_tools
    # git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git ${BUILDWARE_ROOT}\$BUILD_SRC\depot_tools
    if(!(Test-Path "${BUILDWARE_ROOT}\$BUILD_SRC\depot_tools" -PathType Container)) {
        mkdir "${BUILDWARE_ROOT}\$BUILD_SRC\depot_tools"
        Invoke-WebRequest "https://storage.googleapis.com/chrome-infra/depot_tools.zip" -o ${BUILDWARE_ROOT}\$BUILD_SRC\depot_tools.zip
        Expand-Archive -Path ${BUILDWARE_ROOT}\$BUILD_SRC\depot_tools.zip -DestinationPath ${BUILDWARE_ROOT}\$BUILD_SRC\depot_tools
    }
    
    $env:Path = "${BUILDWARE_ROOT}\$BUILD_SRC\depot_tools;$env:Path"
    
    $env:DEPOT_TOOLS_WIN_TOOLCHAIN = 0

    # sync third_party
    python scripts/bootstrap.py
    gclient sync -D
}

# Apply custom patch
if(Test-Path "${BUILDWARE_ROOT}\src\${LIB_NAME}\patch1.ps1" -PathType Leaf) {
    Invoke-Expression -Command "${BUILDWARE_ROOT}\src\${LIB_NAME}\patch1.ps1 ${BUILDWARE_ROOT}\src\${LIB_NAME}"
}

# Config & Build
$install_dir="${BUILDWARE_ROOT}\${INSTALL_ROOT}\${LIB_NAME}"
if(!(Test-Path $install_dir -PathType Container)) {
    mkdir "$install_dir"
}
if ($cb_tool -eq 'cmake') {
    $CONFIG_ALL_OPTIONS += "-DCMAKE_INSTALL_PREFIX=$install_dir"
    $CMAKE_PATCH="${BUILDWARE_ROOT}\src\${LIB_NAME}\CMakeLists.txt"
    if(Test-Path $CMAKE_PATCH -PathType Leaf) {
        Copy-Item $CMAKE_PATCH .\CMakeLists.txt
    }
    if($LIB_NAME -eq 'curl') {
        $openssl_dir="${BUILDWARE_ROOT}\${INSTALL_ROOT}\openssl\"
        $CONFIG_ALL_OPTIONS += "-DOPENSSL_INCLUDE_DIR=${openssl_dir}\include"
        $CONFIG_ALL_OPTIONS += "-DOPENSSL_LIB_DIR=${openssl_dir}\lib"

        # $zlib_dir="${BUILDWARE_ROOT}\${INSTALL_ROOT}\zlib\"
        # $CONFIG_ALL_OPTIONS += "-DZLIB_INCLUDE_DIR=${zlib_dir}\include"
        # $CONFIG_ALL_OPTIONS += "-DZLIB_LIBRARY=${zlib_dir}\lib\zlib.lib" # dyn link zlib, for static use zlibstatic.lib
    }
    
    if ($env:NO_DLL -eq 'true') {
        $CONFIG_ALL_OPTIONS += "-DBUILD_SHARED_LIBS=OFF"
        $CONFIG_ALL_OPTIONS = [System.Collections.ArrayList]$CONFIG_ALL_OPTIONS
        $CONFIG_ALL_OPTIONS.Remove("-DBUILD_SHARED_LIBS=ON")
    }
    
    cmake -S . -B build_$BUILD_ARCH $CONFIG_ALL_OPTIONS
    cmake --build build_$BUILD_ARCH --config Release
    cmake --install build_$BUILD_ARCH
}
elseif($cb_tool -eq 'perl') { # only openssl use perl
    if ($env:NO_DLL -eq 'true') {
        $CONFIG_ALL_OPTIONS += "no-shared"
    }
    $CONFIG_ALL_OPTIONS += "--prefix=$install_dir", "--openssldir=$install_dir"
    # $zlib_dir="${BUILDWARE_ROOT}\${INSTALL_ROOT}\zlib\"
    # $CONFIG_ALL_OPTIONS += "--with-zlib-include=$zlib_dir\include", "--with-zlib-lib=${zlib_dir}\lib\zlib.lib"
    
    Write-Output ("CONFIG_ALL_OPTIONS=$CONFIG_ALL_OPTIONS, Count={0}" -f $CONFIG_ALL_OPTIONS.Count)
    perl Configure $CONFIG_ALL_OPTIONS
    perl configdata.pm --dump
    nmake install_sw
}
elseif($cb_tool -eq 'gn') { # google gn: for angleproject only
    # configure
    Write-Output ("CONFIG_ALL_OPTIONS=$CONFIG_ALL_OPTIONS, Count={0}" -f $CONFIG_ALL_OPTIONS.Count)

    $cmdStr="gn gen out/release --sln=angle-release --ide=vs2022 ""--args=target_cpu=\""$BUILD_ARCH\"" $CONFIG_ALL_OPTIONS"""
    Write-Output "Executing command: {$cmdStr}"
    cmd /c $cmdStr

    # build
    $BUILD_CFG = $null
    if ($BUILD_ARCH -eq 'x86') {
        $BUILD_CFG = "GN|Win32"
    } else {
        $BUILD_CFG = "GN|$BUILD_ARCH"
    }

    $cmdStr="autoninja -C out\release"
    Write-Output "Executing command: {$cmdStr}"
    cmd /c $cmdStr
}
else { # regard a buildscript .bat provide by the library
    if(Test-Path "${cb_dir}\${cb_script}" -PathType Leaf) {
        Push-Location $cb_dir
        Write-Output "Execute build script $cb_script provided by library builtin...";
        Invoke-Expression -Command ".\$cb_script"
        Pop-Location
    }
}

Set-Location ..\..\

$install_script = "src\${LIB_NAME}\install1.ps1"
if(Test-Path $install_script -PathType Leaf) {
    Invoke-Expression -Command "$install_script $install_dir ${BUILDWARE_ROOT}\$BUILD_SRC\${LIB_SRC}"
}

$clean_script = "src\${LIB_NAME}\clean1.ps1"
if(Test-Path $clean_script -PathType Leaf) {
    Invoke-Expression -Command "$clean_script $install_dir"
}
