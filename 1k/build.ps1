#
# Copyright (c) 2021 Bytedance Inc.
#
# params: LIB_NAME ARCH INSTALL_ROOT BUILDWARE_ROOT

$LIB_NAME = $args[0]
$ARCH = $args[1]
$INSTALL_ROOT = $args[2]
$BUILDWARE_ROOT = $args[3]

$PROPS_FILE="src\${LIB_NAME}\build.yml"
if(!(Test-Path $PROPS_FILE -PathType Leaf)) {
    Write-Output "repo config for lib not exists!"
    return -1
}

# Parse openssl checkout tag, such as OpenSSL_1_1_1k
$PROPS = ConvertFrom-Yaml -Yaml (Get-Content $PROPS_FILE -raw)
$repo = $PROPS.'repo'
$ver = $PROPS.'ver'
$tag_prefix = $PROPS.'tag_prefix'
$tag_dot2ul = $PROPS.'tag_dot2ul'
$config_options_msw=$PROPS.'config_options_msw'
$cb_tool = $PROPS.'cb_tool'
$cmake_target = $PROPS.'cmake_target'

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
    if($ARCH -eq "x86") {
        $CONFIG_ALL_OPTIONS += '-A', 'Win32'
    }
    # only support vs2019+, default is Win64
}
else { # opnel openssl use perl
    if($ARCH -eq "x86") {
        $CONFIG_ALL_OPTIONS += 'VC-WIN32'
    }
    else {
        $CONFIG_ALL_OPTIONS += 'VC-WIN64A'
    }
}

$CONFIG_ALL_OPTIONS += $CONFIG_OPTIONS

# Checkout repo
Set-Location buildsrc
if(!(Test-Path $LIB_NAME -PathType Container)) {
    if ($repo.EndsWith('.git')) {
        Write-Output "Checking out $repo, please wait..."
        git clone -q $repo $LIB_NAME
        Set-Location $LIB_NAME
        git checkout $release_tag
    }
    #else {
    #    $outputFile = "${libname}.zip" # Split-Path https://github.com/openssl/openssl/archive/refs/tags/OpenSSL_1_1_1k.zip -leaf
    #    echo "Downloading $repo ---> $outputFile"
    #    curl $repo -o .\$outputFile
    #    Expand-Archive -Path $outputFile -DestinationPath .\
    #    cd $LIB_NAME
    #}
}
else {
    Set-Location $LIB_NAME
}

# Config & Build
$install_dir="${BUILDWARE_ROOT}\${INSTALL_ROOT}\${LIB_NAME}"
if(!(Test-Path $install_dir -PathType Container)) {
    mkdir "$install_dir"
}
if ($cb_tool -eq 'cmake') {
    if(!$cmake_target) {
        $cmake_target = 'INSTALL'
    }
    $CONFIG_ALL_OPTIONS += "-DCMAKE_INSTALL_PREFIX=$install_dir"
    Write-Output ("CONFIG_ALL_OPTIONS=$CONFIG_ALL_OPTIONS, Count={0}" -f $CONFIG_ALL_OPTIONS.Count)
    cmake -S . -B build_$ARCH $CONFIG_ALL_OPTIONS
    cmake --build build_$ARCH --config Release --target $cmake_target
}
else { # only openssl use perl
    $CONFIG_ALL_OPTIONS += "--prefix=$install_dir", "--openssldir=$install_dir"
    Write-Output ("CONFIG_ALL_OPTIONS=$CONFIG_ALL_OPTIONS, Count={0}" -f $CONFIG_ALL_OPTIONS.Count)
    perl Configure $CONFIG_ALL_OPTIONS
    nmake install
}

Set-Location ..\..\

$clean_script = "src\${LIB_NAME}\clean.ps1"
if(Test-Path $clean_script -PathType Leaf) {
    Invoke-Expression -Command "$clean_script $install_dir"
}
