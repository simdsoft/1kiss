DIST_ROOT=$1
LIB_NAME=curl
DIST_DIR="${DIST_ROOT}/${LIB_NAME}"

dist_lib ${LIB_NAME} ${DIST_DIR} $DISTF_NATIVES

# # create flat lib for ios
# if [ -f "install_ios_arm/${LIB_NAME}/lib/libcurl.a" ] ; then
#   lipo -create install_ios_arm/${LIB_NAME}/lib/libcurl.a install_ios_arm64/${LIB_NAME}/lib/libcurl.a install_ios_x64/${LIB_NAME}/lib/libcurl.a -output ${DIST_DIR}/lib/ios/libcurl.a
# else
#   lipo -create install_ios_arm64/${LIB_NAME}/lib/libcurl.a install_ios_x64/${LIB_NAME}/lib/libcurl.a -output ${DIST_DIR}/lib/ios/libcurl.a
# fi

# # create flat lib for tvos
# if [ -f "install_tvos_arm/${LIB_NAME}/lib/libcurl.a" ] ; then
#   lipo -create install_tvos_arm/${LIB_NAME}/lib/libcurl.a install_tvos_arm64/${LIB_NAME}/lib/libcurl.a install_tvos_x64/${LIB_NAME}/lib/libcurl.a -output ${DIST_DIR}/lib/tvos/libcurl.a
# else
#   lipo -create install_tvos_arm64/${LIB_NAME}/lib/libcurl.a install_tvos_x64/${LIB_NAME}/lib/libcurl.a -output ${DIST_DIR}/lib/tvos/libcurl.a
# fi

# # check the flat lib
# lipo -info ${DIST_DIR}/lib/ios/libcurl.a

# # check the flat lib
# lipo -info ${DIST_DIR}/lib/tvos/libcurl.a


# # create fat lib for mac
# lipo -create install_osx_arm64/${LIB_NAME}/lib/libcurl.a install_osx_x64/${LIB_NAME}/lib/libcurl.a  -output ${DIST_DIR}/lib/mac/libcurl.a


# # check the fat lib
# lipo -info ${DIST_DIR}/lib/mac/libcurl.a

xcodebuild -create-xcframework \
  -library install_ios_arm64/${LIB_NAME}/lib/libcurl.a \
  -library install_ios_x64/${LIB_NAME}/lib/libcurl.a \
  -library install_ios_arm64_sim/${LIB_NAME}/lib/libcurl.a \
  -library install_tvos_arm64/${LIB_NAME}/lib/libcurl.a \
  -library install_tvos_x64/${LIB_NAME}/lib/libcurl.a \
  -library install_tvos_arm64_sim/${LIB_NAME}/lib/libcurl.a \
  -library install_osx_x64/${LIB_NAME}/lib/libcurl.a \
  -library install_osx_arm64/${LIB_NAME}/lib/libcurl.a \
  -output ${DIST_DIR}/lib/curl.xcframework
