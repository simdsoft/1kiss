DIST_ROOT=$1
LIB_NAME=cares
DIST_DIR="${DIST_ROOT}/${LIB_NAME}"

dist_lib ${LIB_NAME} ${DIST_DIR} $DISTF_ALL

# create flat lib for ios
if [ -f "install_ios_arm/${LIB_NAME}/lib/libcares.a" ] ; then
  lipo -create install_ios_arm/${LIB_NAME}/lib/libcares.a install_ios_arm64/${LIB_NAME}/lib/libcares.a install_ios_x64/${LIB_NAME}/lib/libcares.a -output ${DIST_DIR}/prebuilt/ios/libcares.a
else
  lipo -create install_ios_arm64/${LIB_NAME}/lib/libcares.a install_ios_x64/${LIB_NAME}/lib/libcares.a -output ${DIST_DIR}/prebuilt/ios/libcares.a
fi

# create flat lib for tvos
if [ -f "install_tvos_arm/${LIB_NAME}/lib/libcares.a" ] ; then
  lipo -create install_tvos_arm/${LIB_NAME}/lib/libcares.a install_tvos_arm64/${LIB_NAME}/lib/libcares.a install_tvos_x64/${LIB_NAME}/lib/libcares.a -output ${DIST_DIR}/prebuilt/tvos/libcares.a
else
  lipo -create install_tvos_arm64/${LIB_NAME}/lib/libcares.a install_tvos_x64/${LIB_NAME}/lib/libcares.a -output ${DIST_DIR}/prebuilt/tvos/libcares.a
fi

# check the flat lib
lipo -info ${DIST_DIR}/prebuilt/ios/libcares.a

# check the flat lib
lipo -info ${DIST_DIR}/prebuilt/tvos/libcares.a


# create fat lib for mac
lipo -create install_osx_arm64/${LIB_NAME}/lib/libcares.a install_osx_x64/${LIB_NAME}/lib/libcares.a  -output ${DIST_DIR}/prebuilt/mac/libcares.a


# check the fat lib
lipo -info ${DIST_DIR}/prebuilt/mac/libcares.a
