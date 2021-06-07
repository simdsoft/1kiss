#
# Copyright (c) 2021 Bytedance Inc.
#
# params: arch libname

if(-not (Test-Path 'buildsrc' -PathType Container)) {
    mkdir buildsrc
}

$libname=$args[1]
echo "libname=$libname"
$PROPS_FILE="sources\${libname}.properties"
if(-not (Test-Path $PROPS_FILE -PathType Leaf)) {
    echo "repo config for lib not exists!"
    return -1
}

# Install nasm
$nasm_bin = (Resolve-Path .\buildsrc\nasm-2.15.05).Path
if(-not (Test-Path "$nasm_bin" -PathType Container)) {
    curl https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/win64/nasm-2.15.05-win64.zip -o .\buildsrc\nasm-2.15.05-win64.zip
    Expand-Archive -Path nasm-2.15.05-win64.zip -DestinationPath .\buildsrc
}
$env:Path = "$nasm_bin;$env:Path"
nasm -v

# Parse openssl checkout tag, such as OpenSSL_1_1_1k
$PROPS = ConvertFrom-StringData (Get-Content $PROPS_FILE -raw)
$repo = $PROPS.'repo'
$ver = $PROPS.'ver'
$tag_prefix = $PROPS.'tag_prefix'
$tag_dot2ul = $PROPS.'tag_dot2ul'
$config_options_msw=$PROPS.'config_options_msw'

if($tag_dot2ul -eq 'true') {
    $ver = ([Regex]::Replace($ver, '\.', '_'))
}
$release_tag="${tag_prefix}${ver}"

echo $config_options_msw
$CONFIG_OPTIONS=($config_options_msw -split ' ')

# CONFIG_ALL_OPTIONS
$CONFIG_ALL_OPTIONS=@()

# Determine build target & config options
if($env:BUILD_ARCH -eq "x86_64") {
    $CONFIG_ALL_OPTIONS += 'VC-WIN64A'
}
else {
    $CONFIG_ALL_OPTIONS += 'VC-WIN32'
}

$CONFIG_ALL_OPTIONS += $CONFIG_OPTIONS

# Checkout repo
cd buildsrc
if(-not (Test-Path $libname -PathType Container)) {
    if ($repo.EndsWith('.git')) {
        echo "Checking out $repo, please wait..."
        git clone -q $repo $libname
        cd $libname
        git checkout $release_tag
    }
    #else {
    #    $outputFile = "${libname}.zip" # Split-Path https://github.com/openssl/openssl/archive/refs/tags/OpenSSL_1_1_1k.zip -leaf
    #    echo "Downloading $repo ---> $outputFile"
    #    curl $repo -o .\$outputFile
    #    Expand-Archive -Path $outputFile -DestinationPath .\
    #    cd $libname
    #}
}
else {
    cd $libname
}

# Config & Build
$src_root=(Resolve-Path .\).Path
$INSTALL_NAME="windows_${env:BUILD_ARCH}"
$install_dir="$src_root\$INSTALL_NAME"
$CONFIG_ALL_OPTIONS += "--prefix=$install_dir", "--openssldir=$install_dir"
mkdir "$install_dir"
echo ("CONFIG_ALL_OPTIONS=$CONFIG_ALL_OPTIONS, Count={0}" -f $CONFIG_ALL_OPTIONS.Count)
perl Configure $CONFIG_ALL_OPTIONS
nmake
nmake install

# Delete files what we don't want
del "$install_dir\html" -recurse
del "$install_dir\lib\engines-1_1" -recurse
del "$install_dir\bin\*.pl"
del "$install_dir\bin\*.pdb"
del "$install_dir\bin\*.exe"

cd ..\..\

# Export INSTALL_NAME for uploading
echo "INSTALL_NAME=$INSTALL_NAME" >> ${env:GITHUB_ENV}
