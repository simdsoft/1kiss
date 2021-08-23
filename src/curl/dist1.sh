DIST_ROOT=$1
LIB_NAME=curl
DIST_DIR="${DIST_ROOT}/${LIB_NAME}"

# copy_inc_and_libs ${LIB_NAME} ${DIST_DIR} jconfig.h config_ab.h.in

# create flat lib for ios
lipo -create install_ios_arm/${LIB_NAME}/lib/libcurl.a install_ios_arm64/${LIB_NAME}/lib/libcurl.a install_ios_x64/${LIB_NAME}/lib/libcurl.a -output ${DIST_DIR}/prebuilt/ios/libcurl.a

# check the flat lib
lipo -info ${DIST_DIR}/prebuilt/ios/libcurl.a
