$target_os = $args[0]
$target_arch = $args[1]
$install_dir = $args[2]

if ($is_win_family) {
    Push-Location 'src'
    .\msvcbuild.bat
    Pop-Location
}
else {
    # config
    $CONFIG_TARGET = $null
    if ($target_os -eq 'android') {
        $NDKBIN = $env:ANDROID_NDK_BIN
        if ( "$target_arch" -eq "arm64" ) {
            $NDKCROSS = "$NDKBIN/aarch64-linux-android-"
            $NDKCC = "$NDKBIN/aarch64-linux-android$android_api_level-clang"
            $HOST_CC = "`"gcc`""
        }
        elseif ( "$target_arch" -eq "armv7" ) {
            $NDKCROSS = "$NDKBIN/arm-linux-androideabi-"
            $NDKCC = "$NDKBIN/armv7a-linux-androideabi$android_api_level-clang"
            $HOST_CC = "`"gcc -m32`""
        }
        else {
            $NDKCROSS = "$NDKBIN/i686-linux-android-"
            $NDKCC = "$NDKBIN/i686-linux-android$android_api_level-clang"
            $HOST_CC = "`"gcc -m32`""
        }
        # create symlink for cross commands: 'ar' and 'strip' used by luajit makefile
        if ( !(Test-Path "${NDKCROSS}ar" -PathType Leaf)) {
            ln $NDKBIN/llvm-ar ${NDKCROSS}ar
        }
        if ( !(Test-Path "${NDKCROSS}strip" -PathType Leaf) ) {
            ln $NDKBIN/llvm-strip ${NDKCROSS}strip
        }
        $CONFIG_TARGET = "HOST_CC=$HOST_CC CROSS=$NDKCROSS STATIC_CC=$NDKCC DYNAMIC_CC=`"$NDKCC -fPIC`" TARGET_LD=$NDKCC TARGET_SYS=`"Linux`""
        println CONFIG_TARGET=$CONFIG_TARGET
    }
    elseif ($is_apple_family) {
        $env:MACOSX_DEPLOYMENT_TARGET = '10.12'
        # regard ios,tvos x64 as simulator
        if ($target_arch -eq 'x64' -and ($target_os -eq 'ios' -or $target_os -eq 'tvos')) {
            $SDK_NAME = $(nsdk1k $XCODE_VERSION $target_os 1)
        }
        else {
            $SDK_NAME = $(nsdk1k $env:XCODE_VERSION $target_os)
        }
        println "SDK_NAME=$SDK_NAME"

        $target_uarch = $target_arch
        if ($target_arch -eq 'x64') { $target_uarch = 'x86_64' }

        $ISDKP=$(xcrun --sdk $SDK_NAME --show-sdk-path)
        $ICC=$(xcrun --sdk $SDK_NAME --find clang)
        $ISDKF="-arch $target_uarch -isysroot $ISDKP"
        $TARGET_SYS = if ($target_os -eq 'osx') { 'Darwin' } else { 'iOS' }
        $CONFIG_TARGET="DEFAULT_CC=clang HOST_CC=`"$HOST_CC`" CROSS=`"$(dirname $ICC)/`" TARGET_FLAGS=`"$ISDKF`" TARGET_SYS=$TARGET_SYS XCFLAGS=`"$XCFLAGS`" LUAJIT_A=libluajit.a"
    }

    # build
    if ($CONFIG_TARGET) {
        if (!$IsWIn) {
            echo "$CONFIG_TARGET" | xargs make V=1
        } else {
            throw "Can't build luajit for $target_os on windows host machine"
        }
    }
    else {
        make V=1
    }

    # install
    $install_script = Join-Path $PSScriptRoot 'install1.ps1'
    &$install_script $install_dir $(Get-Location).Path
}
