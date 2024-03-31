DIST_ROOT=$1
LIB_NAME=zlib
DIST_DIR="${DIST_ROOT}/${LIB_NAME}"

dist_lib ${LIB_NAME} ${DIST_DIR} $DISTF_NATIVES

# # create flat lib for ios
# if [ -f "install_ios_arm/${LIB_NAME}/lib/libz.a" ] ; then
#   lipo -create install_ios_arm/${LIB_NAME}/lib/libz.a install_ios_arm64/${LIB_NAME}/lib/libz.a install_ios_x64/${LIB_NAME}/lib/libz.a -output ${DIST_DIR}/lib/ios/libz.a
# else
#   lipo -create install_ios_arm64/${LIB_NAME}/lib/libz.a install_ios_x64/${LIB_NAME}/lib/libz.a -output ${DIST_DIR}/lib/ios/libz.a
# fi

# # create flat lib for tvos
# if [ -f "install_tvos_arm/${LIB_NAME}/lib/libz.a" ] ; then
#   lipo -create install_tvos_arm/${LIB_NAME}/lib/libz.a install_tvos_arm64/${LIB_NAME}/lib/libz.a install_tvos_x64/${LIB_NAME}/lib/libz.a -output ${DIST_DIR}/lib/tvos/libz.a
# else
#   lipo -create install_tvos_arm64/${LIB_NAME}/lib/libz.a install_tvos_x64/${LIB_NAME}/lib/libz.a -output ${DIST_DIR}/lib/tvos/libz.a
# fi

# # check the flat lib
# lipo -info ${DIST_DIR}/lib/ios/libz.a

# # check the flat lib
# lipo -info ${DIST_DIR}/lib/tvos/libz.a

# # create fat lib for mac
# lipo -create install_osx_arm64/${LIB_NAME}/lib/libz.a install_osx_x64/${LIB_NAME}/lib/libz.a -output ${DIST_DIR}/lib/mac/libz.a

# check the fat lib
# lipo -info ${DIST_DIR}/lib/ios/libz.a

xcodebuild -create-xcframework \
  -library install_ios_arm64/${LIB_NAME}/lib/libz.a \
  -library install_ios_x64/${LIB_NAME}/lib/libz.a \
  -library install_ios_arm64_sim/${LIB_NAME}/lib/libz.a \
  -library install_tvos_arm64/${LIB_NAME}/lib/libz.a \
  -library install_tvos_x64/${LIB_NAME}/lib/libz.a \
  -library install_tvos_arm64_sim/${LIB_NAME}/lib/libz.a \
  -library install_osx_x64/${LIB_NAME}/lib/libz.a \
  -library install_osx_arm64/${LIB_NAME}/lib/libz.a \
  -output ${DIST_DIR}/lib/zlib.xcframework

# overrite zconf.h with common header
cp -f src/zlib/zconf.h ${DIST_DIR}/include/
