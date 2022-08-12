DIST_ROOT=$1
LIB_NAME=glsl-optimizer
DIST_DIR="${DIST_ROOT}/${LIB_NAME}"

copy_inc_and_libs ${LIB_NAME} ${DIST_DIR}

# create fat lib for ios
lipo -create install_ios_arm/${LIB_NAME}/lib/libglcpp-library.a install_ios_arm64/${LIB_NAME}/lib/libglcpp-library.a install_ios_x64/${LIB_NAME}/lib/libglcpp-library.a -output ${DIST_DIR}/prebuilt/ios/libglcpp-library.a
lipo -create install_ios_arm/${LIB_NAME}/lib/libglsl_optimizer.a install_ios_arm64/${LIB_NAME}/lib/libglsl_optimizer.a install_ios_x64/${LIB_NAME}/lib/libglsl_optimizer.a -output ${DIST_DIR}/prebuilt/ios/libglsl_optimizer.a
lipo -create install_ios_arm/${LIB_NAME}/lib/libmesa.a install_ios_arm64/${LIB_NAME}/lib/libmesa.a install_ios_x64/${LIB_NAME}/lib/libmesa.a -output ${DIST_DIR}/prebuilt/ios/libmesa.a



# check the fat lib
lipo -info ${DIST_DIR}/prebuilt/ios/libglcpp-library.a
lipo -info ${DIST_DIR}/prebuilt/ios/libglsl_optimizer.a
lipo -info ${DIST_DIR}/prebuilt/ios/libmesa.a

# create fat lib for mac
lipo -create install_osx_arm64/${LIB_NAME}/lib/libglcpp-library.a install_osx_x64/${LIB_NAME}/lib/libglcpp-library.a -output ${DIST_DIR}/prebuilt/mac/libglcpp-library.a
lipo -create install_osx_arm64/${LIB_NAME}/lib/libglsl_optimizer.a install_osx_x64/${LIB_NAME}/lib/libglsl_optimizer.a -output ${DIST_DIR}/prebuilt/mac/libglsl_optimizer.a
lipo -create install_osx_arm64/${LIB_NAME}/lib/libmesa.a install_osx_x64/${LIB_NAME}/lib/libmesa.a -output ${DIST_DIR}/prebuilt/mac/libmesa.a

# check the fat lib
lipo -info ${DIST_DIR}/prebuilt/mac/libglcpp-library.a
lipo -info ${DIST_DIR}/prebuilt/mac/libglsl_optimizer.a
lipo -info ${DIST_DIR}/prebuilt/mac/libmesa.a
