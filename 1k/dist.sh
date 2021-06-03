ls -R

openssl_ver=$(cat build.ini | grep -w 'openssl_ver' | cut -d '=' -f 2 | tr -d ' \n')
openssl_ver=${openssl_ver//./_}

OPENSSL_DIST_NAME="openssl_${openssl_ver}"
OPENSSL_DIST_DIR="openssl-dist/${OPENSSL_DIST_NAME}"

# mkdir for commen
mkdir -p ${OPENSSL_DIST_DIR}/include

# mkdir for opensslconf.h
mkdir -p ${OPENSSL_DIST_DIR}/include/win32/openssl
mkdir -p ${OPENSSL_DIST_DIR}/include/linux/openssl
mkdir -p ${OPENSSL_DIST_DIR}/include/mac/openssl
mkdir -p ${OPENSSL_DIST_DIR}/include/ios-arm/openssl
mkdir -p ${OPENSSL_DIST_DIR}/include/ios-arm64/openssl
mkdir -p ${OPENSSL_DIST_DIR}/include/ios-x64/openssl
mkdir -p ${OPENSSL_DIST_DIR}/include/android-arm/openssl
mkdir -p ${OPENSSL_DIST_DIR}/include/android-arm64/openssl
mkdir -p ${OPENSSL_DIST_DIR}/include/android-x86/openssl

# mkdir for libs
mkdir -p ${OPENSSL_DIST_DIR}/prebuilt/win32
mkdir -p ${OPENSSL_DIST_DIR}/prebuilt/linux/64-bit
mkdir -p ${OPENSSL_DIST_DIR}/prebuilt/mac
mkdir -p ${OPENSSL_DIST_DIR}/prebuilt/ios
mkdir -p ${OPENSSL_DIST_DIR}/prebuilt/android/armeabi-v7a
mkdir -p ${OPENSSL_DIST_DIR}/prebuilt/android/arm64-v8a
mkdir -p ${OPENSSL_DIST_DIR}/prebuilt/android/x86
ls -R ${OPENSSL_DIST_DIR}

# copy common headers
cp -rf openssl_linux_x86_64/include/openssl ${OPENSSL_DIST_DIR}/include/
rm -rf ${OPENSSL_DIST_DIR}/include/opensslconf.h
cp "1k/opensslconf.h.in" ${OPENSSL_DIST_DIR}/include/opensslconf.h

# copy platform spec opensslconf.h
cp "1k/opensslconf-win32.h.in" ${OPENSSL_DIST_DIR}/include/win32/openssl/opensslconf.h
cp openssl_linux_x86_64/include/openssl/opensslconf.h ${OPENSSL_DIST_DIR}/include/linux/openssl/
cp openssl_osx_x86_64/include/openssl/opensslconf.h ${OPENSSL_DIST_DIR}/include/mac/openssl/
cp openssl_ios_arm/include/openssl/opensslconf.h ${OPENSSL_DIST_DIR}/include/ios-arm/openssl/
cp openssl_ios_arm64/include/openssl/opensslconf.h ${OPENSSL_DIST_DIR}/include/ios-arm64/openssl/
cp openssl_ios_x86_64/include/openssl/opensslconf.h ${OPENSSL_DIST_DIR}/include/ios-x64/openssl/
cp openssl_android_arm/include/openssl/opensslconf.h ${OPENSSL_DIST_DIR}/include/android-arm/openssl/
cp openssl_android_arm64/include/openssl/opensslconf.h ${OPENSSL_DIST_DIR}/include/android-arm64/openssl/
cp openssl_android_x86/include/openssl/opensslconf.h ${OPENSSL_DIST_DIR}/include/android-x86/openssl/

# copy libs
cp openssl_linux_x86_64/lib/*.a ${OPENSSL_DIST_DIR}/prebuilt/linux/64-bit/
cp openssl_osx_x86_64/lib/*.a ${OPENSSL_DIST_DIR}/prebuilt/mac/
cp openssl_android_arm/lib/*.a ${OPENSSL_DIST_DIR}/prebuilt/android/armeabi-v7a/
cp openssl_android_arm64/lib/*.a ${OPENSSL_DIST_DIR}/prebuilt/android/arm64-v8a/
cp openssl_android_x86/lib/*.a ${OPENSSL_DIST_DIR}/prebuilt/android/x86/

# create flat lib for ios
lipo -create openssl_ios_arm/lib/libssl.a openssl_ios_arm64/lib/libssl.a openssl_ios_x86_64/lib/libssl.a -output ${OPENSSL_DIST_DIR}/prebuilt/ios/libssl.a
lipo -create openssl_ios_arm/lib/libcrypto.a openssl_ios_arm64/lib/libcrypto.a openssl_ios_x86_64/lib/libcrypto.a -output ${OPENSSL_DIST_DIR}/prebuilt/ios/libcrypto.a

# check the flat lib
lipo -info ${OPENSSL_DIST_DIR}/prebuilt/ios/libssl.a
lipo -info ${OPENSSL_DIST_DIR}/prebuilt/ios/libcrypto.a

ls -R ${OPENSSL_DIST_DIR}

# Export OPENSSL_DIST_NAME for uploading
echo "OPENSSL_DIST_NAME=$OPENSSL_DIST_NAME" >> $GITHUB_ENV
