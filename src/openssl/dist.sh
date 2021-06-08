DIST_ROOT=$1

DIST_DIR="${DIST_ROOT}/openssl"

# mkdir for commen
mkdir -p ${DIST_DIR}/include

# mkdir for opensslconf.h
mkdir -p ${DIST_DIR}/include/win32/openssl
mkdir -p ${DIST_DIR}/include/linux/openssl
mkdir -p ${DIST_DIR}/include/mac/openssl
mkdir -p ${DIST_DIR}/include/ios-arm/openssl
mkdir -p ${DIST_DIR}/include/ios-arm64/openssl
mkdir -p ${DIST_DIR}/include/ios-x64/openssl
mkdir -p ${DIST_DIR}/include/android-arm/openssl
mkdir -p ${DIST_DIR}/include/android-arm64/openssl
mkdir -p ${DIST_DIR}/include/android-x86/openssl

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
cp -rf install_linux_x64/${LIB_NAME}/include/openssl ${DIST_DIR}/include/
rm -rf ${DIST_DIR}/include/openssl/opensslconf.h
cp "1k/opensslconf.h.in" ${DIST_DIR}/include/openssl/opensslconf.h

# copy platform spec opensslconf.h
cp install_windows_x86/${LIB_NAME}/include/openssl/opensslconf.h ${DIST_DIR}/include/win32/openssl/opensslconf.h
cp install_linux_x64/${LIB_NAME}/include/openssl/opensslconf.h ${DIST_DIR}/include/linux/openssl/
cp install_osx_x64/${LIB_NAME}/include/openssl/opensslconf.h ${DIST_DIR}/include/mac/openssl/
cp install_ios_arm/${LIB_NAME}/include/openssl/opensslconf.h ${DIST_DIR}/include/ios-arm/openssl/
cp install_ios_arm64/${LIB_NAME}/include/openssl/opensslconf.h ${DIST_DIR}/include/ios-arm64/openssl/
cp install_ios_x64/${LIB_NAME}/include/openssl/opensslconf.h ${DIST_DIR}/include/ios-x64/openssl/
cp install_android_arm/${LIB_NAME}/include/openssl/opensslconf.h ${DIST_DIR}/include/android-arm/openssl/
cp install_android_arm64/${LIB_NAME}/include/openssl/opensslconf.h ${DIST_DIR}/include/android-arm64/openssl/
cp install_android_x86/${LIB_NAME}/include/openssl/opensslconf.h ${DIST_DIR}/include/android-x86/openssl/

# copy libs
cp install_windows_x86/${LIB_NAME}/lib/*.lib ${DIST_DIR}/prebuilt/win32/
cp install_windows_x86/${LIB_NAME}/bin/*.dll ${DIST_DIR}/prebuilt/win32/
cp install_linux_x64/${LIB_NAME}/lib/*.a ${DIST_DIR}/prebuilt/linux/x64/
cp install_osx_x64/${LIB_NAME}/lib/*.a ${DIST_DIR}/prebuilt/mac/
cp install_android_arm/${LIB_NAME}/lib/*.a ${DIST_DIR}/prebuilt/android/armeabi-v7a/
cp install_android_arm64/${LIB_NAME}/lib/*.a ${DIST_DIR}/prebuilt/android/arm64-v8a/
cp install_android_x86/${LIB_NAME}/lib/*.a ${DIST_DIR}/prebuilt/android/x86/

# create flat lib for ios
lipo -create install_ios_arm/${LIB_NAME}/lib/libssl.a install_ios_arm64/${LIB_NAME}/lib/libssl.a install_ios_x64/${LIB_NAME}/lib/libssl.a -output ${DIST_DIR}/prebuilt/ios/libssl.a
lipo -create install_ios_arm/${LIB_NAME}/lib/libcrypto.a install_ios_arm64/${LIB_NAME}/lib/libcrypto.a install_ios_x64/${LIB_NAME}/lib/libcrypto.a -output ${DIST_DIR}/prebuilt/ios/libcrypto.a

# check the flat lib
lipo -info ${DIST_DIR}/prebuilt/ios/libssl.a
lipo -info ${DIST_DIR}/prebuilt/ios/libcrypto.a
