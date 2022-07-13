BUILD_TARGET=$1
BUILD_ARCH=$2

echo "RUNNER_OS=$RUNNER_OS"

BUILDWARE_ROOT=`pwd`
INSTALL_ROOT="install_${BUILD_TARGET}_${BUILD_ARCH}"

# Create buildsrc tmp dir for build libs
mkdir -p "buildsrc"

if [ "$RUNNER_OS" = "Linux" ] ; then
    sudo apt-get update
    sudo apt-get install gcc-multilib --fix-missing
fi

# Install nasm
nasm_bin=$(which nasm) || true
if [ -f "$nasm_bin" ] ; then
    echo "The nasm installed at $nasm_bin"
else
    if [ "$RUNNER_OS" = "Linux" ] ; then
        sudo apt-get install nasm
    elif [ "$RUNNER_OS" = "macOS" ] ; then
        brew install nasm
    fi
fi

# Check whether nasm install succeed
nasm_bin=$(which nasm) || true
echo "nasm_bin=$nasm_bin"
if [ "$nasm_bin" = "" ] ; then
    echo "Install nasm failed!"
    return -1
fi

# Install android ndk
if [ "$BUILD_TARGET" = "android" ] ; then
    # Determine builder host OS
    if [ "$RUNNER_OS" = "Linux" ] ; then
        NDK_PLAT=linux
    elif [ "$RUNNER_OS" = "macOS" ] ; then
        NDK_PLAT=darwin
    fi
    ndk_ver=$(cat ndk.properties | grep -w 'ndk_ver' | cut -d '=' -f 2 | tr -d '\n')
    
    # Check exist ndk
    if [ -d "$ANDROID_NDK" ] ; then
        echo "Using exist android ndk: $ANDROID_NDK"
    else
        ndk_rver=${ndk_ver:0:3}
        ndk_pkg_suffix=-x86_64
        if [[ $ndk_rver >= 'r23' ]] ; then
            ndk_pkg_suffix=
        fi
        
        if [ ! -d "buildsrc/android-ndk-${ndk_ver}" ] ; then
            NDK_URL="https://dl.google.com/android/repository/android-ndk-${ndk_ver}-${NDK_PLAT}${ndk_pkg_suffix}.zip"
            echo "Downloading ${NDK_URL}..."
            wget -q -O buildsrc/android-ndk-${ndk_ver}-${NDK_PLAT}${ndk_pkg_suffix}.zip https://dl.google.com/android/repository/android-ndk-${ndk_ver}-${NDK_PLAT}${ndk_pkg_suffix}.zip
            unzip -q buildsrc/android-ndk-${ndk_ver}-${NDK_PLAT}${ndk_pkg_suffix}.zip -d buildsrc/
        else
            echo "The directory buildsrc/android-ndk-${ndk_ver} exists"
        fi
        export ANDROID_NDK=`pwd`/buildsrc/android-ndk-${ndk_ver}
    fi
    
    # Export alias ENVs
    export ANDROID_NDK_HOME=$ANDROID_NDK
    export ANDROID_NDK_ROOT=$ANDROID_NDK
    export PATH=$ANDROID_NDK/toolchains/llvm/prebuilt/${NDK_PLAT}-x86_64/bin:$ANDROID_NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/${NDK_PLAT}-x86_64/bin:$PATH
    echo PATH=$PATH
fi

# Build libs
source 1k/build1.sh zlib $BUILD_TARGET $BUILD_ARCH $INSTALL_ROOT
source 1k/build1.sh openssl $BUILD_TARGET $BUILD_ARCH $INSTALL_ROOT
source 1k/build1.sh curl $BUILD_TARGET $BUILD_ARCH $INSTALL_ROOT
source 1k/build1.sh jpeg-turbo $BUILD_TARGET $BUILD_ARCH $INSTALL_ROOT
source 1k/build1.sh luajit $BUILD_TARGET $BUILD_ARCH $INSTALL_ROOT

# Export INSTALL_ROOT for uploading
if [ -n "$GITHUB_ENV" ] ; then
    echo "INSTALL_ROOT=$INSTALL_ROOT"
    echo "INSTALL_ROOT=$INSTALL_ROOT" >> ${GITHUB_ENV}
fi
