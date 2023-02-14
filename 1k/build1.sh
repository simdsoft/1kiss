#
# Copyright (c) 2021-2023 Bytedance Inc.
#

BUILDWARE_ROOT=`pwd`

LIB_NAME=$1
BUILD_TARGET=$2
BUILD_ARCH=$3
INSTALL_ROOT=$4

echo "LIB_NAME=$LIB_NAME"
echo "BUILD_TARGET=$BUILD_TARGET"
echo "BUILD_ARCH=$BUILD_ARCH"
echo "INSTALL_ROOT=$INSTALL_ROOT"

# Parse android ndk
android_api_level=$(cat ndk.properties | grep -w 'android_api_level' | cut -d '=' -f 2 | tr -d ' \n')
android_api_level_arm64=$(cat ndk.properties | grep -w 'android_api_level_arm64' | cut -d '=' -f 2 | tr -d '\n')
android_api_level_x86_64=$(cat ndk.properties | grep -w 'android_api_level_x86_64' | cut -d '=' -f 2 | tr -d '\n')

function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) >= 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

# Prepare env
PROPS_FILE="src/${LIB_NAME}/build.yml"

eval $(parse_yaml $PROPS_FILE)

echo "repo=$repo"
echo "config_options_embed=$config_options_embed"
echo "cb_tool=$cb_tool"
echo "cb_target=$cb_target"
echo "bw_targets=$bw_targets"
echo "bw_archs=$bw_archs"

if [ ! "$bw_targets" = "" ] && [[ ! $bw_targets == *"$BUILD_TARGET"* ]] ; then
    # skip
    echo "Skip build $LIB_NAME which is not allow for target: $BUILD_TARGET"
    return 0
fi

if [ ! "$bw_archs" = "" ] && [[ ! $bw_archs == *"$BUILD_ARCH"* ]] ; then
    echo "Skip build $LIB_NAME which is not allow for arch: $BUILD_ARCH"
    return 0
fi

if [ "$tag_dot2ul" = "true" ]; then
    ver=${ver//./_}
fi 
release_tag="${tag_prefix}${ver}"

echo "BUILD_TARGET=$BUILD_TARGET"
echo "BUILD_ARCH=$BUILD_ARCH"

# Determine build target & config options
CONFIG_OPTIONS=$config_options_unix
if [ "$BUILD_TARGET" = "linux" ] ; then
    CONFIG_TARGET=
elif [ "$BUILD_TARGET" = "osx" ] ; then
    if [ "$cb_tool" = "cmake" ] ; then
            MAC_ARCH=""
        if [ "$BUILD_ARCH" = "arm64" ] ; then
            MAC_ARCH=arm64
        elif [ "$BUILD_ARCH" = "x64" ] ; then
            MAC_ARCH=x86_64
        fi
        CONFIG_TARGET="-GXcode -DCMAKE_OSX_ARCHITECTURES=${MAC_ARCH}"
    elif [ "$cb_tool" = "perl" ] ; then # openssl TODO: move to custom config.sh
        BUILD_MACHINE=`uname -m`
        if [ "$BUILD_ARCH" = "x64" ] ; then
            CONFIG_TARGET=darwin64-x86_64-cc
        elif [ "$BUILD_ARCH" = "arm64" ] ; then
            CONFIG_TARGET=darwin64-arm64-cc
        fi
    else # luajit TODO: move to custom config.sh
        CONFIG_TARGET=
        export MACOSX_DEPLOYMENT_TARGET=10.12

        SDK_NAME=$(nsdk1k $XCODE_VER osx)
        echo "SDK_NAME=$SDK_NAME"
        HOST_CC="gcc -std=c99"
        XCFLAGS=" -DLJ_NO_SYSTEM=1 "
        if [ "$BUILD_ARCH" = "arm64" ] ; then
            ARCH_NAME=arm64
        elif [ "$BUILD_ARCH" = "x64" ] ; then
             ARCH_NAME=x86_64
        fi
        ISDKP=$(xcrun --sdk $SDK_NAME --show-sdk-path)
        ICC=$(xcrun --sdk $SDK_NAME --find clang)
        ISDKF="-arch $ARCH_NAME -isysroot $ISDKP"
        CONFIG_TARGET="DEFAULT_CC=clang HOST_CC=\"$HOST_CC\" CROSS=\"$(dirname $ICC)/\" TARGET_FLAGS=\"$ISDKF\" TARGET_SYS=Darwin XCFLAGS=\"$XCFLAGS\" LUAJIT_A=libluajit.a"

    fi
elif [ "$BUILD_TARGET" = "ios" ] ; then
    if [ "$cb_tool" = "cmake" ] ; then
        PLATFORM=""
        if [ "$BUILD_ARCH" = "arm" ] ; then
            PLATFORM=OS
        elif [ "$BUILD_ARCH" = "arm64" ] ; then
            PLATFORM=OS64
        elif [ "$BUILD_ARCH" = "x64" ] ; then
            PLATFORM=SIMULATOR64
        fi
        CONFIG_TARGET="-GXcode -DCMAKE_TOOLCHAIN_FILE=${BUILDWARE_ROOT}/1k/ios.toolchain.cmake -DPLATFORM=${PLATFORM} -DDEPLOYMENT_TARGET=9.0"
    elif [ "$cb_tool" = "perl" ] ; then # openssl TODO: move to custom config.sh
        # Export OPENSSL_LOCAL_CONFIG_DIR for perl script file 'openssl/Configure' 
        export OPENSSL_LOCAL_CONFIG_DIR="$BUILDWARE_ROOT/1k" 

        IOS_PLATFORM=OS
        if [ "$BUILD_ARCH" = "arm" ] ; then
            CONFIG_TARGET=ios-cross-armv7s
        elif [ "$BUILD_ARCH" = "arm64" ] ; then
            CONFIG_TARGET=ios-cross-arm64
        elif [ "$BUILD_ARCH" = "x64" ] ; then
            CONFIG_TARGET=ios-sim-cross-x86_64
            IOS_PLATFORM=Simulator
        fi
        
        export CROSS_TOP=$(xcode-select -print-path)/Platforms/iPhone${IOS_PLATFORM}.platform/Developer
        export CROSS_SDK=iPhone${IOS_PLATFORM}.sdk
    else # luajit TODO: move to custom config.sh
        SDK_NAME=iphoneos
        HOST_CC="gcc -std=c99"
        XCFLAGS=" -DLJ_NO_SYSTEM=1 "
        if [ "$BUILD_ARCH" = "arm" ] ; then
            ARCH_NAME=armv7
            HOST_CC="gcc -m32 -std=c99"
            XCFLAGS=" -DLJ_NO_SYSTEM=1 -Wno-ignored-optimization-argument "
            XCODEVER=`xcodebuild -version|head -n 1|sed 's/Xcode \([0-9]*\)/\1/g'`
            ISOLD_XCODEVER=`echo "$XCODEVER <= 10.1" | bc`
            echo "ISOLD_XCODEVER=$ISOLD_XCODEVER, XCODEVER=$XCODEVER"
            if [ "$ISOLD_XCODEVER" = "0" ] ; then
                echo "Build luajit ios-armv7 require Xcode version <= 10.1, but $XCODEVER provided!"
                SKIP_CI=true
            fi
        elif [ "$BUILD_ARCH" = "arm64" ] ; then
            ARCH_NAME=arm64
        elif [ "$BUILD_ARCH" = "x64" ] ; then
            SDK_NAME=iphonesimulator
            ARCH_NAME=x86_64
        fi
        ISDKP=$(xcrun --sdk $SDK_NAME --show-sdk-path)
        ICC=$(xcrun --sdk $SDK_NAME --find clang)
        ISDKF="-fembed-bitcode -arch $ARCH_NAME -isysroot $ISDKP"
        CONFIG_TARGET="DEFAULT_CC=clang HOST_CC=\"$HOST_CC\" CROSS=\"$(dirname $ICC)/\" TARGET_FLAGS=\"$ISDKF\" TARGET_SYS=iOS XCFLAGS=\"$XCFLAGS\" LUAJIT_A=libluajit.a"
    fi

    CONFIG_OPTIONS="$CONFIG_OPTIONS $config_options_embed"
elif [ "$BUILD_TARGET" = "tvos" ] ; then
    if [ "$cb_tool" = "cmake" ] ; then
        PLATFORM=""
        if [ "$BUILD_ARCH" = "arm64" ] ; then
            PLATFORM=TVOS
        elif [ "$BUILD_ARCH" = "x64" ] ; then
            PLATFORM=SIMULATOR_TVOS
        fi
        CONFIG_TARGET="-GXcode -DCMAKE_TOOLCHAIN_FILE=${BUILDWARE_ROOT}/1k/ios.toolchain.cmake -DPLATFORM=${PLATFORM} -DDEPLOYMENT_TARGET=9.0"
    elif [ "$cb_tool" = "perl" ] ; then # openssl TODO: move to custom config.sh
        # Export OPENSSL_LOCAL_CONFIG_DIR for perl script file 'openssl/Configure' 
        export OPENSSL_LOCAL_CONFIG_DIR="$BUILDWARE_ROOT/1k" 

        TVOS_PLATFORM=OS
        if [ "$BUILD_ARCH" = "arm64" ] ; then
            CONFIG_TARGET=tvos-cross-arm64
        elif [ "$BUILD_ARCH" = "x64" ] ; then
            CONFIG_TARGET=tvos-sim-cross-x86_64
            TVOS_PLATFORM=Simulator
        fi
        
        export CROSS_TOP=$(xcode-select -print-path)/Platforms/AppleTV${TVOS_PLATFORM}.platform/Developer
        export CROSS_SDK=AppleTV${TVOS_PLATFORM}.sdk
    else # luajit TODO: move to custom config.sh
        SDK_NAME=appletvos
        HOST_CC="gcc -std=c99"
        XCFLAGS=" -DLJ_NO_SYSTEM=1 "
        if [ "$BUILD_ARCH" = "arm64" ] ; then
            ARCH_NAME=arm64
        elif [ "$BUILD_ARCH" = "x64" ] ; then
            SDK_NAME=appletvsimulator
            ARCH_NAME=x86_64
        fi
        ISDKP=$(xcrun --sdk $SDK_NAME --show-sdk-path)
        ICC=$(xcrun --sdk $SDK_NAME --find clang)
        ISDKF="-fembed-bitcode -arch $ARCH_NAME -isysroot $ISDKP"
        CONFIG_TARGET="DEFAULT_CC=clang HOST_CC=\"$HOST_CC\" CROSS=\"$(dirname $ICC)/\" TARGET_FLAGS=\"$ISDKF\" TARGET_SYS=iOS XCFLAGS=\"$XCFLAGS\" LUAJIT_A=libluajit.a"
    fi

    CONFIG_OPTIONS="$CONFIG_OPTIONS $config_options_embed"
elif [ "$BUILD_TARGET" = "android" ] ; then
    if [ "$cb_tool" = "cmake" ] ; then
        if [ "$BUILD_ARCH" = "arm" ] ; then
            CONFIG_TARGET="-DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake -DANDROID_ABI=armeabi-v7a -DANDROID_NATIVE_API_LEVEL=${android_api_level}"
        elif [ "$BUILD_ARCH" = "arm64" ] ; then
            CONFIG_TARGET="-DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake -DANDROID_ABI=arm64-v8a -DANDROID_NATIVE_API_LEVEL=${android_api_level_arm64}"
        elif [ "$BUILD_ARCH" = "x86" ] ; then
            CONFIG_TARGET="-DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake -DANDROID_ABI=x86 -DANDROID_NATIVE_API_LEVEL=${android_api_level}"
        elif [ "$BUILD_ARCH" = "x64" ] ; then
            CONFIG_TARGET="-DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake -DANDROID_ABI=x86_64 -DANDROID_NATIVE_API_LEVEL=${android_api_level_x86_64}"
        fi
    elif [ "$cb_tool" = "perl" ] ; then # openssl TODO: move to custom config.sh
        if [ "$BUILD_ARCH" = "arm64" ] ; then
            CONFIG_TARGET="android-$BUILD_ARCH -D__ANDROID_API__=$android_api_level_arm64"
        elif [ "$BUILD_ARCH" = "x64" ] ; then
            CONFIG_TARGET="android-x86_64 -D__ANDROID_API__=$android_api_level_x86_64"
        else
            CONFIG_TARGET="android-$BUILD_ARCH -D__ANDROID_API__=$android_api_level"
            if [ "$BUILD_ARCH" = "x86" ] ; then
                CONFIG_TARGET="$CONFIG_TARGET -latomic"
            fi
        fi
    else # luajit TODO: move to custom config.sh
        NDKBIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$NDK_PLAT-x86_64/bin
        NDKCROSS_LINKER=$NDKBIN/llvm-
        if [ "$BUILD_ARCH" = "arm64" ] ; then
            NDKCROSS=$NDKBIN/aarch64-linux-android-
            NDKCC=$NDKBIN/aarch64-linux-android$android_api_level_arm64-clang
            CONFIG_TARGET="HOST_CC=\"gcc\" CROSS=$NDKCROSS CROSS_LINKER=$NDKCROSS_LINKER STATIC_CC=$NDKCC DYNAMIC_CC=\"$NDKCC -fPIC\" TARGET_LD=$NDKCC TARGET_SYS=\"Linux\""
        elif [ "$BUILD_ARCH" = "arm" ] ; then
            NDKCROSS=$NDKBIN/arm-linux-androideabi-
            NDKCC=$NDKBIN/armv7a-linux-androideabi$android_api_level-clang
            CONFIG_TARGET="HOST_CC=\"gcc -m32\" CROSS=$NDKCROSS CROSS_LINKER=$NDKCROSS_LINKER STATIC_CC=$NDKCC DYNAMIC_CC=\"$NDKCC -fPIC\" TARGET_LD=$NDKCC TARGET_SYS=\"Linux\""
        else
            NDKCROSS=$NDKBIN/i686-linux-android-
            NDKCC=$NDKBIN/i686-linux-android$android_api_level-clang
            CONFIG_TARGET="HOST_CC=\"gcc -m32\" CROSS=$NDKCROSS CROSS_LINKER=$NDKCROSS_LINKER STATIC_CC=$NDKCC DYNAMIC_CC=\"$NDKCC -fPIC\" TARGET_LD=$NDKCC TARGET_SYS=\"Linux\""
        fi
        echo NDKCC=$NDKCC
    fi

    CONFIG_OPTIONS="$CONFIG_OPTIONS $config_options_embed"
else
  return 1
fi

echo CONFIG_TARGET=${CONFIG_TARGET}
echo CONFIG_OPTIONS=${CONFIG_OPTIONS}
echo CROSS_TOP=${CROSS_TOP}
echo CROSS_SDK=${CROSS_SDK}

mkdir -p "buildsrc"
cd buildsrc

# Determine LIB_SRC
if [[ $repo == *".git" ]] ; then
    LIB_SRC=$LIB_NAME
else
    LIB_SRC=$(basename "${repo%.*}")
    if [[ $LIB_SRC == *".tar" ]] ; then
        LIB_SRC=$(basename "${LIB_SRC%.*}")
    fi
fi

# Checking out...
if [ ! -d $LIB_SRC ] ; then
    if [[ $repo == *".git" ]] ; then
        # Checkout lib
        echo "Checking out $repo, please wait..."
        git clone -q $repo $LIB_SRC
        pwd
        cd $LIB_SRC
        git checkout $release_tag
        git submodule update --init --recursive
    else
        if [[ $repo == *".tar.gz" ]] ; then
            outputFile="${LIB_SRC}.tar.gz"
        else
            outputFile="${LIB_SRC}.zip"
        fi
        echo "Downloading $repo ---> $outputFile"
        curl $repo -o ./$outputFile

        if [[ $repo == *".tar.gz" ]] ; then
            tar -xvzf ./$outputFile
        else
            unzip -q ./$outputFile -d ./
        fi
        cd $LIB_SRC
    fi
else
    cd $LIB_SRC
fi

# Apply custom patch
if [ -f "../../src/${LIB_NAME}/patch1.sh" ] ; then
    source "../../src/${LIB_NAME}/patch1.sh"  "../../src/${LIB_NAME}" `pwd`
fi

# Config & Build
install_dir="${BUILDWARE_ROOT}/${INSTALL_ROOT}/${LIB_NAME}"
mkdir -p $install_dir

if [ "$cb_tool" = "cmake" ] ; then
    CONFIG_ALL_OPTIONS="$CONFIG_TARGET $CONFIG_OPTIONS -DCMAKE_INSTALL_PREFIX=$install_dir"
    CMAKE_PATCH="${BUILDWARE_ROOT}/src/${LIB_NAME}/CMakeLists.txt"
    if [ -f "${CMAKE_PATCH}" ] ; then
        cp -f ${CMAKE_PATCH} ./
    fi
    if [ "$LIB_NAME" = "curl" ]; then
        openssl_dir="${BUILDWARE_ROOT}/${INSTALL_ROOT}/openssl/"
        CONFIG_ALL_OPTIONS="$CONFIG_ALL_OPTIONS -DOPENSSL_INCLUDE_DIR=${openssl_dir}include -DOPENSSL_LIB_DIR=${openssl_dir}lib"
    fi
    echo CONFIG_ALL_OPTIONS="$CONFIG_ALL_OPTIONS"
    cmake "-DCMAKE_C_FLAGS=-fPIC" -B build_$BUILD_ARCH $CONFIG_ALL_OPTIONS
    if [ "$cb_target" = "" ] ; then
        cmake --build build_$BUILD_ARCH --config Release
        cmake --install build_$BUILD_ARCH
    else
        cmake --build build_$BUILD_ARCH --config Release --target $cb_target
        cmake --install build_$BUILD_ARCH --config Release --component $cb_target
    fi
elif [ "$cb_tool" = "perl" ] ; then # openssl TODO: move to custom build.sh
    CONFIG_ALL_OPTIONS="$CONFIG_TARGET $CONFIG_OPTIONS --prefix=$install_dir --openssldir=$install_dir"
    echo CONFIG_ALL_OPTIONS=${CONFIG_ALL_OPTIONS}
    if [ "$BUILD_TARGET" = "linux" ] ; then
        ./config $CONFIG_ALL_OPTIONS && perl configdata.pm --dump
    else
        ./Configure $CONFIG_ALL_OPTIONS && perl configdata.pm --dump
    fi
    make VERBOSE=1
    make install_sw
elif [ "$cb_tool" = "make" ] ; then # luajit # TODO: move to custom build.sh
    if [ ! "$SKIP_CI" = "true" ] ; then
        CONFIG_ALL_OPTIONS="$CONFIG_TARGET $CONFIG_OPTIONS"
        echo CONFIG_ALL_OPTIONS="$CONFIG_ALL_OPTIONS"
        
        if [ ! -z "${CONFIG_ALL_OPTIONS// }" ] ; then
          echo "$CONFIG_ALL_OPTIONS" | xargs make V=1
        else
          make V=1
        fi
        
        # have custom install script?
        if [ -f "../../src/${LIB_NAME}/install1.sh" ] ; then
            install_script="src/${LIB_NAME}/install1.sh"
        else
            make install PREFIX=$install_dir 
        fi
    else
        echo "Skip build luajit ios-armv7 on xcode-10.3 or later!"
    fi
else 
    echo "unknown cross build tool provided!"
    cd ../../
    return 2
fi

cd ../../

if [ ! "$install_script" = "" ] && [ -f "$install_script" ] ; then
    source $install_script $install_dir "${BUILDWARE_ROOT}/buildsrc/${LIB_SRC}"
fi

clean_script="src/${LIB_NAME}/clean1.sh"
if [ -f "$clean_script" ] ; then
    source $clean_script $install_dir
fi
