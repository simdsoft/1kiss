BUILD_TARGET=$1
BUILD_ARCH=$2
BUILD_LIBS=$3

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
    
    # Check exist ndk
    if [ "$GITHUB_ACTIONS" = "" ] && [ -d "$ANDROID_NDK" ] ; then
        echo "Using exist android ndk: $ANDROID_NDK"
        ndk_rev=$(cat $ANDROID_NDK/source.properties | grep -w 'Pkg.Revision' | cut -d '=' -f 2 | tr -d '\n')
        ndk_ver=${ndk_rev:0:2}
    else
        ndk_rev=$(cat ndk.properties | grep -w 'ndk_rev' | cut -d '=' -f 2 | tr -d '\n')
        ndk_ver=${ndk_rev:1:2}
        ndk_pkg_suffix=-x86_64
        if [[ $ndk_ver > '22' ]] ; then
            ndk_pkg_suffix=
        fi

        echo "ndk_pkg_suffix=$ndk_pkg_suffix"
        
        if [ ! -d "buildsrc/android-ndk-${ndk_rev}" ] ; then
            NDK_URL="https://dl.google.com/android/repository/android-ndk-${ndk_rev}-${NDK_PLAT}${ndk_pkg_suffix}.zip"
            echo "Downloading ${NDK_URL}..."
            wget -q -O buildsrc/android-ndk-${ndk_rev}-${NDK_PLAT}${ndk_pkg_suffix}.zip https://dl.google.com/android/repository/android-ndk-${ndk_rev}-${NDK_PLAT}${ndk_pkg_suffix}.zip
            unzip -q buildsrc/android-ndk-${ndk_rev}-${NDK_PLAT}${ndk_pkg_suffix}.zip -d buildsrc/
        else
            echo "The directory buildsrc/android-ndk-${ndk_rev} exists"
        fi
        export ANDROID_NDK=`pwd`/buildsrc/android-ndk-${ndk_rev}
    fi

    echo "ndk_rev=$ndk_rev"
    echo "ndk_ver=$ndk_ver"
    
    # Export alias ENVs
    export ANDROID_NDK_HOME=$ANDROID_NDK
    export ANDROID_NDK_ROOT=$ANDROID_NDK
    export PATH=$ANDROID_NDK/toolchains/llvm/prebuilt/${NDK_PLAT}-x86_64/bin:$ANDROID_NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/${NDK_PLAT}-x86_64/bin:$PATH
    echo PATH=$PATH
fi

# compile nsdk1k on macOS
if [ "$RUNNER_OS" = "macOS" ] ; then
    echo "XCODE_VERSION=$XCODE_VERSION"
    mkdir -p build
    g++ -std=c++17 1k/nsdk1k.cpp -o build/nsdk1k
    PATH=`pwd`/build:$PATH
fi

# Build libs
if [ "$BUILD_LIBS" = "" ] ; then
   BUILD_LIBS="zlib,openssl,cares,curl,jpeg-turbo,glsl-optimizer,luajit"
fi

libs_arr=(${BUILD_LIBS//,/ })
libs_count=${#libs_arr[@]}
echo "Building $libs_count libs ..."
for (( i=0; i<${libs_count}; ++i )); do
  source 1k/build1.sh ${libs_arr[$i]} $BUILD_TARGET $BUILD_ARCH $INSTALL_ROOT
  # Reset options
  cb_target=
  bw_targets=
  bw_archs=
done

# Export INSTALL_ROOT for uploading
if [ -n "$GITHUB_ENV" ] ; then
    echo "INSTALL_ROOT=$INSTALL_ROOT"
    echo "INSTALL_ROOT=$INSTALL_ROOT" >> ${GITHUB_ENV}
fi
