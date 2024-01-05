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
        $is_32bit_target = $target_arch -eq 'armv7' -or $target_arch -eq 'x86'
        if ($is_32bit_target) {
            if ($IsLinux) {
                sudo apt update
                sudo apt install gcc-multilib --fix-missing
            }
        }
        $NDKBIN = $env:ANDROID_NDK_BIN
        $cross_toolchain = @{
            arm64 = 'aarch64-linux-android'; 
            x64   = 'x86_64-linux-android'; 
            armv7 = 'armv7a-linux-androideabi'; 
            x86   = 'i686-linux-android'
        }[$target_arch]

        $NDKCROSS = "$NDKBIN/$cross_toolchain-"
        $NDKCC = "$NDKBIN/$cross_toolchain$android_api_level-clang" 

        $HOST_CC = @("`"gcc`"", "`"gcc -m32`"")[$is_32bit_target]
        # create symlink for cross commands: 'ar' and 'strip' used by luajit makefile
        if ( !(Test-Path "${NDKCROSS}ar" -PathType Leaf)) {
            ln $NDKBIN/llvm-ar ${NDKCROSS}ar
        }
        if ( !(Test-Path "${NDKCROSS}strip" -PathType Leaf) ) {
            ln $NDKBIN/llvm-strip ${NDKCROSS}strip
        }
        $CONFIG_TARGET = @("HOST_CC=$HOST_CC", "CROSS=$NDKCROSS", "STATIC_CC=$NDKCC", "DYNAMIC_CC=`"$NDKCC -fPIC`"", "TARGET_LD=$NDKCC", "TARGET_SYS=`"Linux`"")
    }
    elseif ($is_apple_family) {
        if (!$env:XCODE_VERSION) { throw "Missing env var: XCODE_VERSION" }
        if ($target_os -eq 'osx') {
            $env:MACOSX_DEPLOYMENT_TARGET = '10.12'
        }
        # regard ios,tvos x64 as simulator
        if ($target_arch -eq 'x64' -and ($target_os -eq 'ios' -or $target_os -eq 'tvos')) {
            $SDK_NAME = $(nsdk1k $env:XCODE_VERSION $target_os 1)
        }
        else {
            $SDK_NAME = $(nsdk1k $env:XCODE_VERSION $target_os)
        }
        println "SDK_NAME=$SDK_NAME"

        $target_uarch = $target_arch
        if ($target_arch -eq 'x64') { $target_uarch = 'x86_64' }

        $HOST_CC = "gcc -std=c99"
        $XCFLAGS = "-DLJ_NO_SYSTEM=1"
        $ISDKP = $(xcrun --sdk $SDK_NAME --show-sdk-path)
        $ICC = $(xcrun --sdk $SDK_NAME --find clang)
        $ISDKF = "-arch $target_uarch -isysroot $ISDKP"
        $TARGET_SYS = if ($target_os -eq 'osx') { 'Darwin' } else { 'iOS' }
        $CONFIG_TARGET = @('DEFAULT_CC=clang', "HOST_CC=`"$HOST_CC`"", "CROSS=`"$(dirname $ICC)/`"", "TARGET_FLAGS=`"$ISDKF`"", "TARGET_SYS=$TARGET_SYS", "XCFLAGS=`"$XCFLAGS`"", "LUAJIT_A=libluajit.a")
    }

    # build
    if ($CONFIG_TARGET) {
        if (!$IsWIn) {
            println "CONFIG_TARGET=$CONFIG_TARGET, Count=$($CONFIG_TARGET.Count)"
            make V=1 $CONFIG_TARGET
        }
        else {
            throw "Can't build luajit for $target_os on windows host machine"
        }
    }
    else {
        make V=1
    }
}
