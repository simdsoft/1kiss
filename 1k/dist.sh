DIST_REVISION=$1
DIST_SUFFIX=$2

DIST_NAME=buildware_dist

if [ "${DIST_REVISION}" != "" ]; then
    DIST_NAME="${DIST_NAME}_${DIST_REVISION}"
fi

if [ "${DIST_SUFFIX}" != "" ]; then
    DIST_NAME="${DIST_NAME}${DIST_SUFFIX}"
fi

DIST_ROOT=`pwd`/${DIST_NAME}
mkdir -p $DIST_ROOT

function copy_inc_and_libs {
    LIB_NAME=$1
    DIST_DIR=$2
    CONF_HEADER=$3
    CONF_TEMPLATE=$4
    # [optional] INC_DIR=openssl/
    INC_DIR=$5

    # mkdir for commen
    mkdir -p ${DIST_DIR}/include

    # mkdir for platform spec config header file
    if [ "$CONF_TEMPLATE" = "config.h.in" ] ; then
        mkdir -p ${DIST_DIR}/include/win32/${INC_DIR}
        mkdir -p ${DIST_DIR}/include/win64/${INC_DIR}
        mkdir -p ${DIST_DIR}/include/linux/${INC_DIR}
        mkdir -p ${DIST_DIR}/include/mac/${INC_DIR}
        mkdir -p ${DIST_DIR}/include/ios-arm/${INC_DIR}
        mkdir -p ${DIST_DIR}/include/ios-arm64/${INC_DIR}
        mkdir -p ${DIST_DIR}/include/ios-x64/${INC_DIR}
        mkdir -p ${DIST_DIR}/include/tvos-arm64/${INC_DIR}
        mkdir -p ${DIST_DIR}/include/tvos-x64/${INC_DIR}
        mkdir -p ${DIST_DIR}/include/android-arm/${INC_DIR}
        mkdir -p ${DIST_DIR}/include/android-arm64/${INC_DIR}
        mkdir -p ${DIST_DIR}/include/android-x86/${INC_DIR}
        mkdir -p ${DIST_DIR}/include/android-x86_64/${INC_DIR}
    elif [ "$CONF_TEMPLATE" = "config_ab.h.in" ] ; then
        mkdir -p ${DIST_DIR}/include/win32/${INC_DIR}
        mkdir -p ${DIST_DIR}/include/unix/${INC_DIR}
    fi

    # mkdir for libs
    mkdir -p ${DIST_DIR}/prebuilt/windows/x86
    mkdir -p ${DIST_DIR}/prebuilt/windows/x64
    mkdir -p ${DIST_DIR}/prebuilt/linux/x64
    mkdir -p ${DIST_DIR}/prebuilt/mac/x64
    mkdir -p ${DIST_DIR}/prebuilt/mac/arm64
    mkdir -p ${DIST_DIR}/prebuilt/ios
    mkdir -p ${DIST_DIR}/prebuilt/tvos
    mkdir -p ${DIST_DIR}/prebuilt/android/armeabi-v7a
    mkdir -p ${DIST_DIR}/prebuilt/android/arm64-v8a
    mkdir -p ${DIST_DIR}/prebuilt/android/x86
    mkdir -p ${DIST_DIR}/prebuilt/android/x86_64

    # copy common headers
    cp -rf install_linux_x64/${LIB_NAME}/include/${INC_DIR} ${DIST_DIR}/include/${INC_DIR}

    if [ "$CONF_HEADER" != "" ] ; then
        rm -rf ${DIST_DIR}/include/${INC_DIR}${CONF_HEADER}

        CONF_CONTENT=$(cat 1k/$CONF_TEMPLATE)
        STYLED_LIB_NAME=${LIB_NAME//-/_}
        CONF_CONTENT=${CONF_CONTENT//@LIB_NAME@/$STYLED_LIB_NAME}
        CONF_CONTENT=${CONF_CONTENT//@INC_DIR@/$INC_DIR}
        CONF_CONTENT=${CONF_CONTENT//@CONF_HEADER@/$CONF_HEADER}
        echo "$CONF_CONTENT" >> ${DIST_DIR}/include/${INC_DIR}${CONF_HEADER}

        # copy platform spec config header file
        if [ "$CONF_TEMPLATE" = "config.h.in" ] ; then
            cp install_windows_x86/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/win32/${INC_DIR}
            cp install_windows_x64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/win64/${INC_DIR}
            cp install_linux_x64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/linux/${INC_DIR}
            cp install_osx_x64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/mac/${INC_DIR}
            # cp install_ios_arm/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/ios-arm/${INC_DIR}
            cp install_ios_arm64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/ios-arm64/${INC_DIR}
            cp install_ios_x64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/ios-x64/${INC_DIR}
            cp install_tvos_arm64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/tvos-arm64/${INC_DIR}
            cp install_tvos_x64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/tvos-x64/${INC_DIR}
            cp install_android_arm/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/android-arm/${INC_DIR}
            cp install_android_arm64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/android-arm64/${INC_DIR}
            cp install_android_x86/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/android-x86/${INC_DIR}
            cp install_android_x64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/android-x86_64/${INC_DIR}

        elif [ "$CONF_TEMPLATE" = "config_ab.h.in" ] ; then
            cp install_windows_x86/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/win32/${INC_DIR}
            cp install_linux_x64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/unix/${INC_DIR}
        fi
    fi

    # copy libs
    cp install_windows_x86/${LIB_NAME}/lib/*.lib ${DIST_DIR}/prebuilt/windows/x86/
    bindir=install_windows_x86/${LIB_NAME}/bin
    if [ -d "$bindir" ] && [ "`ls -A $bindir`" != "" ]; then
        cp -r install_windows_x86/${LIB_NAME}/bin/* ${DIST_DIR}/prebuilt/windows/x86/
    fi
    cp install_windows_x64/${LIB_NAME}/lib/*.lib ${DIST_DIR}/prebuilt/windows/x64/
    bindir=install_windows_x64/${LIB_NAME}/bin
    if [ -d "$bindir" ] && [ "`ls -A $bindir`" != "" ]; then
        cp -r install_windows_x64/${LIB_NAME}/bin/* ${DIST_DIR}/prebuilt/windows/x64/
    fi
    
    cp install_linux_x64/${LIB_NAME}/lib/*.a ${DIST_DIR}/prebuilt/linux/x64/
    cp install_osx_x64/${LIB_NAME}/lib/*.a ${DIST_DIR}/prebuilt/mac/x64
    cp install_osx_arm64/${LIB_NAME}/lib/*.a ${DIST_DIR}/prebuilt/mac/arm64
    cp install_android_arm/${LIB_NAME}/lib/*.a ${DIST_DIR}/prebuilt/android/armeabi-v7a/
    cp install_android_arm64/${LIB_NAME}/lib/*.a ${DIST_DIR}/prebuilt/android/arm64-v8a/
    cp install_android_x86/${LIB_NAME}/lib/*.a ${DIST_DIR}/prebuilt/android/x86/
    cp install_android_x64/${LIB_NAME}/lib/*.a ${DIST_DIR}/prebuilt/android/x86_64/

}

function copy_win_dlls {
    LIB_NAME=$1
    DIST_DIR=$2
    bindir=install_windows_x86/${LIB_NAME}/bin
    if [ -d "$bindir" ] && [ "`ls -A $bindir`" != "" ]; then
        cp -r install_windows_x86/${LIB_NAME}/bin/* ${DIST_DIR}/prebuilt/windows/x86/
    fi
    bindir=install_windows_x64/${LIB_NAME}/bin
    if [ -d "$bindir" ] && [ "`ls -A $bindir`" != "" ]; then
        cp -r install_windows_x64/${LIB_NAME}/bin/* ${DIST_DIR}/prebuilt/windows/x64/
    fi
}

# try download something can't build from github action
# if [ "$TRAVIS_ARTIFACTS_REL" != "" ] ; then
#     set +e
#     TRAVIS_ARTIFACTS_URL="https://github.com/adxeproject/buildware/releases/download/$TRAVIS_ARTIFACTS_REL/install_ios_arm.zip"
#     echo "Try download artifacts $TRAVIS_ARTIFACTS_URL"
#     wget -O install_ios_arm.zip "$TRAVIS_ARTIFACTS_URL"
#     if [ "$?" = "0" ]; then
#         unzip -q install_ios_arm.zip -d ./
#     fi
#     set -e
# fi

source src/zlib/dist1.sh $DIST_ROOT
source src/jpeg-turbo/dist1.sh $DIST_ROOT
source src/openssl/dist1.sh $DIST_ROOT
source src/curl/dist1.sh $DIST_ROOT
source src/luajit/dist1.sh $DIST_ROOT

# Because glsl-optimizer only build for macos/ios
# so we disable script abort when copy command fail for other targets
set +e
source src/glsl-optimizer/dist1.sh $DIST_ROOT
set -e

# create dist package
DIST_PACKAGE=${DIST_NAME}.zip
zip -q -r ${DIST_PACKAGE} ${DIST_NAME}

# Export DIST_NAME & DIST_PACKAGE for uploading
if [ "$GITHUB_ENV" != "" ] ; then
    echo "DIST_NAME=$DIST_NAME" >> $GITHUB_ENV
    echo "DIST_PACKAGE=${DIST_PACKAGE}" >> $GITHUB_ENV
fi
