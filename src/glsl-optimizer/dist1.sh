DIST_ROOT=$1
LIB_NAME=glsl-optimizer
DIST_DIR="${DIST_ROOT}/${LIB_NAME}"

dist_lib ${LIB_NAME} ${DIST_DIR} $DISTF_APPL

# create fat lib for ios
if [ -f "install_ios_arm/${LIB_NAME}/lib/libglsl_optimizer.a" ] ; then
  lipo -create install_ios_arm/${LIB_NAME}/lib/libglcpp-library.a install_ios_arm64/${LIB_NAME}/lib/libglcpp-library.a install_ios_x64/${LIB_NAME}/lib/libglcpp-library.a -output ${DIST_DIR}/prebuilt/ios/libglcpp-library.a
  lipo -create install_ios_arm/${LIB_NAME}/lib/libglsl_optimizer.a install_ios_arm64/${LIB_NAME}/lib/libglsl_optimizer.a install_ios_x64/${LIB_NAME}/lib/libglsl_optimizer.a -output ${DIST_DIR}/prebuilt/ios/libglsl_optimizer.a
  lipo -create install_ios_arm/${LIB_NAME}/lib/libmesa.a install_ios_arm64/${LIB_NAME}/lib/libmesa.a install_ios_x64/${LIB_NAME}/lib/libmesa.a -output ${DIST_DIR}/prebuilt/ios/libmesa.a
else
  lipo -create install_ios_arm64/${LIB_NAME}/lib/libglcpp-library.a install_ios_x64/${LIB_NAME}/lib/libglcpp-library.a -output ${DIST_DIR}/prebuilt/ios/libglcpp-library.a
  lipo -create install_ios_arm64/${LIB_NAME}/lib/libglsl_optimizer.a install_ios_x64/${LIB_NAME}/lib/libglsl_optimizer.a -output ${DIST_DIR}/prebuilt/ios/libglsl_optimizer.a
  lipo -create install_ios_arm64/${LIB_NAME}/lib/libmesa.a install_ios_x64/${LIB_NAME}/lib/libmesa.a -output ${DIST_DIR}/prebuilt/ios/libmesa.a
fi

# create fat lib for tvos
if [ -f "install_tvos_arm/${LIB_NAME}/lib/libglsl_optimizer.a" ] ; then
  lipo -create install_tvos_arm/${LIB_NAME}/lib/libglcpp-library.a install_tvos_arm64/${LIB_NAME}/lib/libglcpp-library.a install_tvos_x64/${LIB_NAME}/lib/libglcpp-library.a -output ${DIST_DIR}/prebuilt/tvos/libglcpp-library.a
  lipo -create install_tvos_arm/${LIB_NAME}/lib/libglsl_optimizer.a install_tvos_arm64/${LIB_NAME}/lib/libglsl_optimizer.a install_tvos_x64/${LIB_NAME}/lib/libglsl_optimizer.a -output ${DIST_DIR}/prebuilt/tvos/libglsl_optimizer.a
  lipo -create install_tvos_arm/${LIB_NAME}/lib/libmesa.a install_tvos_arm64/${LIB_NAME}/lib/libmesa.a install_tvos_x64/${LIB_NAME}/lib/libmesa.a -output ${DIST_DIR}/prebuilt/tvos/libmesa.a
else
  lipo -create install_tvos_arm64/${LIB_NAME}/lib/libglcpp-library.a install_tvos_x64/${LIB_NAME}/lib/libglcpp-library.a -output ${DIST_DIR}/prebuilt/tvos/libglcpp-library.a
  lipo -create install_tvos_arm64/${LIB_NAME}/lib/libglsl_optimizer.a install_tvos_x64/${LIB_NAME}/lib/libglsl_optimizer.a -output ${DIST_DIR}/prebuilt/tvos/libglsl_optimizer.a
  lipo -create install_tvos_arm64/${LIB_NAME}/lib/libmesa.a install_tvos_x64/${LIB_NAME}/lib/libmesa.a -output ${DIST_DIR}/prebuilt/tvos/libmesa.a
fi

# check the fat lib
lipo -info ${DIST_DIR}/prebuilt/ios/libglcpp-library.a
lipo -info ${DIST_DIR}/prebuilt/ios/libglsl_optimizer.a
lipo -info ${DIST_DIR}/prebuilt/ios/libmesa.a

# check the fat lib
lipo -info ${DIST_DIR}/prebuilt/tvos/libglcpp-library.a
lipo -info ${DIST_DIR}/prebuilt/tvos/libglsl_optimizer.a
lipo -info ${DIST_DIR}/prebuilt/tvos/libmesa.a

# create fat lib for mac
lipo -create install_osx_arm64/${LIB_NAME}/lib/libglcpp-library.a install_osx_x64/${LIB_NAME}/lib/libglcpp-library.a -output ${DIST_DIR}/prebuilt/mac/libglcpp-library.a
lipo -create install_osx_arm64/${LIB_NAME}/lib/libglsl_optimizer.a install_osx_x64/${LIB_NAME}/lib/libglsl_optimizer.a -output ${DIST_DIR}/prebuilt/mac/libglsl_optimizer.a
lipo -create install_osx_arm64/${LIB_NAME}/lib/libmesa.a install_osx_x64/${LIB_NAME}/lib/libmesa.a -output ${DIST_DIR}/prebuilt/mac/libmesa.a

# check the fat lib
lipo -info ${DIST_DIR}/prebuilt/mac/libglcpp-library.a
lipo -info ${DIST_DIR}/prebuilt/mac/libglsl_optimizer.a
lipo -info ${DIST_DIR}/prebuilt/mac/libmesa.a
