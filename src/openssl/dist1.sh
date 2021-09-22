DIST_ROOT=$1
LIB_NAME=openssl
DIST_DIR="${DIST_ROOT}/${LIB_NAME}"

copy_inc_and_libs ${LIB_NAME} ${DIST_DIR} configuration.h config.h.in openssl/

# create flat lib for ios
lipo -create install_ios_arm/${LIB_NAME}/lib/libssl.a install_ios_arm64/${LIB_NAME}/lib/libssl.a install_ios_x64/${LIB_NAME}/lib/libssl.a -output ${DIST_DIR}/prebuilt/ios/libssl.a
lipo -create install_ios_arm/${LIB_NAME}/lib/libcrypto.a install_ios_arm64/${LIB_NAME}/lib/libcrypto.a install_ios_x64/${LIB_NAME}/lib/libcrypto.a -output ${DIST_DIR}/prebuilt/ios/libcrypto.a

# check the flat lib
lipo -info ${DIST_DIR}/prebuilt/ios/libssl.a
lipo -info ${DIST_DIR}/prebuilt/ios/libcrypto.a
