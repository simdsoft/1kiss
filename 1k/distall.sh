DIST_REVISION=$1

DIST_NAME=buildware_dist_${DIST_REVISION}
DIST_ROOT=`pwd`/${DIST_NAME}
mkdir -p $DIST_ROOT

function copy_inc_and_libs {
    LIB_NAME=$1
    DIST_DIR=$2
    CONF_HEADER=$3
    # [optional] INC_DIR=openssl/
    INC_DIR=$4
    
    # mkdir for commen
    mkdir -p ${DIST_DIR}/include

    # mkdir for opensslconf.h
    mkdir -p ${DIST_DIR}/include/win32/${INC_DIR}
    mkdir -p ${DIST_DIR}/include/linux/${INC_DIR}
    mkdir -p ${DIST_DIR}/include/mac/${INC_DIR}
    mkdir -p ${DIST_DIR}/include/ios-arm/${INC_DIR}
    mkdir -p ${DIST_DIR}/include/ios-arm64/${INC_DIR}
    mkdir -p ${DIST_DIR}/include/ios-x64/${INC_DIR}
    mkdir -p ${DIST_DIR}/include/android-arm/${INC_DIR}
    mkdir -p ${DIST_DIR}/include/android-arm64/${INC_DIR}
    mkdir -p ${DIST_DIR}/include/android-x86/${INC_DIR}

    # mkdir for libs
    mkdir -p ${DIST_DIR}/prebuilt/win32
    mkdir -p ${DIST_DIR}/prebuilt/linux/x64
    mkdir -p ${DIST_DIR}/prebuilt/mac
    mkdir -p ${DIST_DIR}/prebuilt/ios
    mkdir -p ${DIST_DIR}/prebuilt/android/armeabi-v7a
    mkdir -p ${DIST_DIR}/prebuilt/android/arm64-v8a
    mkdir -p ${DIST_DIR}/prebuilt/android/x86
    ls -R ${DIST_DIR}

    # copy common headers
    cp -rf install_linux_x64/${LIB_NAME}/include/${INC_DIR} ${DIST_DIR}/include/
    rm -rf ${DIST_DIR}/include/${INC_DIR}${CONF_HEADER}
    cp "1k/${CONF_HEADER}.in" ${DIST_DIR}/include/${INC_DIR}${CONF_HEADER}

    # copy platform spec opensslconf.h
    cp install_windows_x86/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/win32/${INC_DIR}
    cp install_linux_x64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/linux/${INC_DIR}
    cp install_osx_x64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/mac/${INC_DIR}
    cp install_ios_arm/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/ios-arm/${INC_DIR}
    cp install_ios_arm64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/ios-arm64/${INC_DIR}
    cp install_ios_x64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/ios-x64/${INC_DIR}
    cp install_android_arm/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/android-arm/${INC_DIR}
    cp install_android_arm64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/android-arm64/${INC_DIR}
    cp install_android_x86/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/android-x86/${INC_DIR}

    # copy libs
    cp install_windows_x86/${LIB_NAME}/lib/*.lib ${DIST_DIR}/prebuilt/win32/
    cp install_windows_x86/${LIB_NAME}/bin/*.dll ${DIST_DIR}/prebuilt/win32/
    cp install_linux_x64/${LIB_NAME}/lib/*.a ${DIST_DIR}/prebuilt/linux/x64/
    cp install_osx_x64/${LIB_NAME}/lib/*.a ${DIST_DIR}/prebuilt/mac/
    cp install_android_arm/${LIB_NAME}/lib/*.a ${DIST_DIR}/prebuilt/android/armeabi-v7a/
    cp install_android_arm64/${LIB_NAME}/lib/*.a ${DIST_DIR}/prebuilt/android/arm64-v8a/
    cp install_android_x86/${LIB_NAME}/lib/*.a ${DIST_DIR}/prebuilt/android/x86/
}

source src/jpeg-turbo/dist.sh $DIST_ROOT
source src/openssl/dist.sh $DIST_ROOT

# create dist package
DIST_PACKAGE=${DIST_NAME}.zip
zip -q -r ${DIST_PACKAGE} ${DIST_ROOT}

ls -R ${DIST_ROOT}

# Export DIST_NAME & DIST_PACKAGE for uploading
echo "DIST_NAME=$DIST_NAME" >> $GITHUB_ENV
echo "DIST_PACKAGE=${DIST_PACKAGE}" >> $GITHUB_ENV
