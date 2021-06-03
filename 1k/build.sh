# Prepare env
openssl_ver=$(cat source.properties | grep -w 'openssl_ver' | cut -d '=' -f 2 | tr -d ' \n')
openssl_ver=${openssl_ver//./_}
openssl_release_tag=OpenSSL_$openssl_ver
ndk_ver=$(cat source.properties | grep -w 'ndk_ver' | cut -d '=' -f 2 | tr -d ' \n')
openssl_config_options_1=$(cat source.properties | grep -w 'openssl_config_options_1' | cut -d '=' -f 2 | tr -d '\n')
openssl_config_options_2=$(cat source.properties | grep -w 'openssl_config_options_2' | cut -d '=' -f 2 | tr -d '\n')
android_api_level=$(cat source.properties | grep -w 'android_api_level' | cut -d '=' -f 2 | tr -d ' \n')
android_api_level_arm64=$(cat source.properties | grep -w 'android_api_level_arm64' | cut -d '=' -f 2 | tr -d ' \n')

echo "RUNNER_OS=$RUNNER_OS"
echo "BUILD_TARGET=$BUILD_TARGET"
echo "BUILD_ARCH=$BUILD_ARCH"

# Determine build target & config options
OPENSSL_CONFIG_OPTIONS=$openssl_config_options_1
if [ "$BUILD_TARGET" = "linux" ]; then
    OPENSSL_CONFIG_TARGET=
elif [ "$BUILD_TARGET" = "osx" ]; then
    OPENSSL_CONFIG_TARGET=darwin64-x86_64-cc
elif [ "$BUILD_TARGET" = "ios" ]; then
    IOS_PLATFORM=OS
    if [ "$BUILD_ARCH" = "arm" ] ; then
        OPENSSL_CONFIG_TARGET=ios-cross
    elif [ "$BUILD_ARCH" = 'arm64' ] ; then
        OPENSSL_CONFIG_TARGET=ios64-cross
    elif [ "$BUILD_ARCH" = "x86_64" ] ; then
        OPENSSL_CONFIG_TARGET=darwin64-x86_64-cc
        IOS_PLATFORM=Simulator
    fi
    OPENSSL_CONFIG_OPTIONS="$OPENSSL_CONFIG_OPTIONS $openssl_config_options_2"
    export CROSS_TOP=$(xcode-select -print-path)/Platforms/iPhone${IOS_PLATFORM}.platform/Developer
    export CROSS_SDK=iPhone${IOS_PLATFORM}.sdk
elif [ "$BUILD_TARGET" = "android" ] ; then
    if [ "$BUILD_ARCH" = "arm64" ] ; then
        OPENSSL_CONFIG_TARGET="android-$BUILD_ARCH -D__ANDROID_API__=$android_api_level_arm64"
    else
        OPENSSL_CONFIG_TARGET="android-$BUILD_ARCH -D__ANDROID_API__=$android_api_level"
    fi
    OPENSSL_CONFIG_OPTIONS="$OPENSSL_CONFIG_OPTIONS $openssl_config_options_2"
else
  return 0
fi

echo OPENSSL_CONFIG_TARGET=${OPENSSL_CONFIG_TARGET}
echo OPENSSL_CONFIG_OPTIONS=${OPENSSL_CONFIG_OPTIONS}

# Install NDK for android
if [ "$BUILD_TARGET" = "android" ] ; then
    wget -q https://dl.google.com/android/repository/android-ndk-${ndk_ver}-linux-x86_64.zip
    unzip -q android-ndk-${ndk_ver}-linux-x86_64.zip
    export ANDROID_NDK_HOME=`pwd`/android-ndk-${ndk_ver}
    export PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$PATH
    echo PATH=$PATH
fi

# Checkout openssl
git clone -q https://github.com/openssl/openssl.git
pwd
cd openssl 
git checkout $openssl_release_tag
git submodule update --init --recursive

# Config & Build
openssl_src_root=`pwd`
INSTALL_NAME=openssl_${BUILD_TARGET}_${BUILD_ARCH}
openssl_install_dir=$openssl_src_root/$INSTALL_NAME
mkdir $openssl_install_dir
echo $OPENSSL_CONFIG_TARGET $OPENSSL_CONFIG_OPTIONS --prefix=$openssl_install_dir --openssldir=$openssl_install_dir
OPENSSL_CONFIG_ALL_OPTIONS="$OPENSSL_CONFIG_TARGET $OPENSSL_CONFIG_OPTIONS BN_LLONG RC4_CHAR --prefix=$openssl_install_dir --openssldir=$openssl_install_dir"
echo OPENSSL_CONFIG_ALL_OPTIONS=${OPENSSL_CONFIG_ALL_OPTIONS}
if [ "$BUILD_TARGET" = "linux" ] ; then
    ./config $OPENSSL_CONFIG_ALL_OPTIONS && perl configdata.pm --dump
else
    ./Configure $OPENSSL_CONFIG_ALL_OPTIONS && perl configdata.pm --dump
fi
make VERBOSE=1
make install
rm -rf $openssl_install_dir/bin
rm -rf $openssl_install_dir/misc
rm -rf $openssl_install_dir/share

# Export INSTALL_NAME for uploading
echo "INSTALL_NAME=$INSTALL_NAME" >> $GITHUB_ENV
