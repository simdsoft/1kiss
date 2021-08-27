BUILD_TARGET=$1
BUILD_ARCH=$2

echo "RUNNER_OS=$RUNNER_OS"

BUILDWARE_ROOT=`pwd`
INSTALL_ROOT="install_${BUILD_TARGET}_${BUILD_ARCH}"

# Create buildsrc tmp dir for build libs
mkdir -p "buildsrc"

# Install nasm
if [ "$RUNNER_OS" = "macOS" ] ; then
    brew install nasm
else
    sudo apt-get install nasm gcc-multilib
fi

# Check whether nasm install succeed
nasm_bin=$(which nasm)
echo "nasm_bin=$nasm_bin"
if [ "$nasm_bin" = "" ] ; then
    echo "Install nasm failed!"
    return -1
fi

# Install android ndk
if [ "$BUILD_TARGET" = "android" ] ; then
    ndk_ver=$(cat ndk.properties | grep -w 'ndk_ver' | cut -d '=' -f 2 | tr -d '\n')
    if [ ! -d "buildsrc/android-ndk-${ndk_ver}" ] ; then
        echo "Downloading https://dl.google.com/android/repository/android-ndk-${ndk_ver}-linux-x86_64.zip..."
        wget -q -O buildsrc/android-ndk-${ndk_ver}-linux-x86_64.zip https://dl.google.com/android/repository/android-ndk-${ndk_ver}-linux-x86_64.zip
        unzip -q buildsrc/android-ndk-${ndk_ver}-linux-x86_64.zip -d buildsrc/
    else
        echo "The directory buildsrc/android-ndk-${ndk_ver} exists"
    fi
    export ANDROID_NDK_HOME=`pwd`/buildsrc/android-ndk-${ndk_ver}
    export PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$PATH
    echo PATH=$PATH
fi

# Build libs
source 1k/build1.sh jpeg-turbo $BUILD_TARGET $BUILD_ARCH $INSTALL_ROOT
source 1k/build1.sh openssl $BUILD_TARGET $BUILD_ARCH $INSTALL_ROOT
source 1k/build1.sh curl $BUILD_TARGET $BUILD_ARCH $INSTALL_ROOT
source 1k/build1.sh luajit $BUILD_TARGET $BUILD_ARCH $INSTALL_ROOT

# Export INSTALL_ROOT for uploading
if [ -n "$GITHUB_ENV" ] ; then
    echo "INSTALL_ROOT=$INSTALL_ROOT"
    echo "INSTALL_ROOT=$INSTALL_ROOT" >> ${GITHUB_ENV}
fi
