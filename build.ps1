$target_os = $args[0]
$target_arch = $args[1]
$build_libs = $args[2]

Set-Alias println Write-Host

function eval($str) {
    return Invoke-Expression "`"$str`""
}

function mkdirs($path) {
    if (!(Test-Path $path -PathType Container)) {
        New-Item $path -ItemType Directory 1>$null 2>$null
    }
}

println "env:NO_DLL=$env:NO_DLL"

if ($target_arch -eq 'amd64_arm64') {
    $target_arch = 'arm64'
}

$_1k_root = $PSScriptRoot

println "_1k_root=$_1k_root"

$build_script = Join-Path "$_1k_root" "1k/build.ps1"
$fetchd_script = Join-Path "$_1k_root" "1k/fetchd.ps1"
$build_src = Join-Path $_1k_root "buildsrc_$target_os"
$install_path = "install_${target_os}"

if ($target_arch -ne '*') {
    $build_src = "${build_src}_$target_arch"
    $install_path = "${install_path}_$target_arch"
}
$install_root = Join-Path $_1k_root $install_path

# Create buildsrc tmp dir for build libs
mkdirs $build_src

# import yaml parser
if ((Get-Module -ListAvailable -Name powershell-yaml) -eq $null) {
    Install-Module -Name powershell-yaml -Force -Repository PSGallery -Scope CurrentUser
}

if (!$build_libs) {
    $build_libs = "zlib,openssl,cares,curl,jpeg-turbo,luajit"
}

# compile nsdk1k on macOS
if ($IsMacOS) {
    echo "XCODE_VERSION=$env:XCODE_VERSION"
    $1kiss_bin = Join-Path ~/.1kiss "bin"
    mkdirs $1kiss_bin
    g++ -std=c++17 1k/nsdk1k.cpp -o $1kiss_bin/nsdk1k
    $env:PATH = "${1kiss_bin}:${env:PATH}"
}

$build_libs = $build_libs -split ","

. $build_script -p $target_os -a $target_arch -setupOnly -ndkOnly
setup_nasm

if ($target_os -eq 'android') {
    if ($IsMacOS) {
        $NDK_PLAT = 'darwin'
    }
    elseif ($IsLinux) {
        $NDK_PLAT = 'linux'
    }
    else {
        $NDK_PLAT = 'win'
    }
    $ANDROID_NDK = $env:ANDROID_NDK
    $ndk_toolchain_bin = "$ANDROID_NDK/toolchains/llvm/prebuilt/${NDK_PLAT}-x86_64/bin"
    if ($env:PATH.IndexOf($ndk_toolchain_bin) -eq -1) {
        $env:PATH = "$ndk_toolchain_bin$ENV_PATH_SEP$env:PATH"
    }
    println "PATH=$env:PATH"
}

$is_gh_act = "$env:GITHUB_ACTIONS" -eq 'true'
$is_winrt = ($target_os -eq 'winrt')
$is_win_family = $is_winrt -or ($target_os -eq 'win32')
# used by custom build step
$is_apple_family = !!(@{'osx' = $true; 'ios' = $true; 'tvos' = $true }[$TARGET_OS])

mkdirs $install_root

# options_xxx, xxx = msw, unix, embed
$embed_family = ''
if ($is_win_family) {
    $os_family = 'msw'
}
else {
    $os_family = 'unix'
    if ($target_os -eq 'ios' -or $target_os -eq 'tvos' -or $target_os -eq 'android') {
        $embed_family = 'embed'
    }
}

Foreach ($lib_name in $build_libs) {
    $build_conf_path = Join-Path $_1k_root "src/$lib_name/build.yml"
    $build_conf = ConvertFrom-Yaml -Yaml (Get-Content $build_conf_path -raw)
    if ($build_conf.targets -and !$build_conf.targets.contains($target_os)) {
        println "Skip build $lib_name which is not allow for target: $target_os"
        continue
    }
    
    if ($build_conf.archs -and !$build_conf.archs.contains($target_os)) {
        println "Skip build $lib_name which is not allow for arch: $target_os"
        continue
    }

    # preprocess $build_conf.options
    if ($build_conf.options) {
        $build_conf.options = (eval $build_conf.options).Split(' ')
    }
    else {
        $build_conf.options = @()
    }

    if (!$is_host_target -and $build_conf.options_cross) {
        $build_conf.options += (eval $build_conf.options_cross).Split(' ')
    }
    
    if ($build_conf."options_$os_family") {
        $build_conf.options += ($build_conf."options_$os_family" -split ' ')
    }
    if ($build_conf."options_$embed_family") {
        $build_conf.options += ($build_conf."options_$embed_family" -split ' ')
    }
    if ($build_conf."options_$target_os") {
        $build_conf.options += ($build_conf."options_$target_os" -split ' ')
    }

    # fetch repo, return variable: $lib_src
    $rel_script = Join-Path $_1k_root "src/$lib_name/rel1.ps1"
    $version = $build_conf.ver
    $revision = $null # commit_hash
    if (Test-Path $rel_script -PathType Leaf) {
        $version,$revision = &$rel_script $build_conf.ver
    } else {
        $revision = "$($build_conf.tag_prefix)$version"
        if ($build_conf.tag_dot2ul) {
            $revision = $revision.Replace('.', '_')
        }
    }

    $is_gn = $build_conf.cb_tool -eq 'gn'
    if ($is_gn) {
        setup_gclient
    }
    . $fetchd_script -url $build_conf.repo -ver $version -rev $revision -prefix $build_src

    println "Building $lib_name in $lib_src..."
    println "build_conf.options: $($build_conf.options)"
    # patch before build
    $patch_script = Join-Path $_1k_root "src/$lib_name/patch1.ps1"
    if (Test-Path $patch_script -PathType Leaf) {
        &$patch_script $lib_src
    }

    # build&install
    Push-Location $lib_src
    $install_dir = Join-Path $install_root $lib_name
    mkdirs $install_dir
    if ($build_conf.cb_tool -ne 'custom') {
        $_config_options = $build_conf.options
        if ($build_conf.cb_tool -eq 'cmake') {
            if ($is_winrt) {
                $_config_options += "-DCMAKE_VS_WINDOWS_TARGET_PLATFORM_MIN_VERSION=$env:VS_DEPLOYMENT_TARGET"
            }

            if (!$is_win_family) {
                $_config_options += '-DCMAKE_C_FLAGS=-fPIC'
            }

            $_config_options += "-DCMAKE_INSTALL_PREFIX=$install_dir"
        
            &$build_script -p $target_os -a $target_arch -xc $_config_options -xb '--target', 'install'
        } elseif($is_gn) {
            &$build_script -p $target_os -a $target_arch -xc $_config_options -xt 'gn' -t "$($build_conf.cb_target)"
        } else {
            throw "Unsupported cross build tool: $($build_conf.cb_tool)"
        }
    }
    else {
        $custom_build_script = Join-Path $_1k_root "src/$lib_name/build1.ps1"
        . $custom_build_script $target_os $target_arch $install_dir
    }
    Pop-Location

    # clean unnecessary files
    $clean_script = Join-Path $_1k_root "src/$lib_name/clean1.ps1"
    if (Test-Path $clean_script -PathType Leaf) {
        &$clean_script $install_dir
    }

    $version_file = Join-Path $lib_src '_1kiss'
    if (Test-Path $version_file -PathType Leaf) {
        Copy-Item $version_file $install_dir
    }

    # delete lib_src if run in github ci
    if ($is_gh_act) {
        println "Deleting $lib_src"
        Remove-Item $lib_src -Recurse -Force
    }
}

# Export INSTALL_ROOT for uploading
if ($is_gh_act) {
    Write-Output "install_path=$install_path" >> $env:GITHUB_ENV
}
