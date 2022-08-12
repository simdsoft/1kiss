DIST_ROOT=$1
LIB_NAME=jpeg-turbo
DIST_DIR="${DIST_ROOT}/${LIB_NAME}"

copy_inc_and_libs ${LIB_NAME} ${DIST_DIR} jconfig.h config_ab.h.in

# create flat lib for ios
lipo -create install_ios_arm/${LIB_NAME}/lib/libjpeg.a install_ios_arm64/${LIB_NAME}/lib/libjpeg.a install_ios_x64/${LIB_NAME}/lib/libjpeg.a -output ${DIST_DIR}/prebuilt/ios/libjpeg.a

# check the flat lib
lipo -info ${DIST_DIR}/prebuilt/ios/libjpeg.a

# create fat lib for mac
lipo -create install_osx_arm64/${LIB_NAME}/lib/libjpeg.a install_osx_x64/${LIB_NAME}/lib/libjpeg.a -output ${DIST_DIR}/prebuilt/mac/libjpeg.a

# check the fat lib
lipo -info ${DIST_DIR}/prebuilt/mac/libjpeg.a
