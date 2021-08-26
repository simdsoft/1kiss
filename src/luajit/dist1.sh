DIST_ROOT=$1
LIB_NAME=luajit
DIST_DIR="${DIST_ROOT}/${LIB_NAME}"

copy_inc_and_libs ${LIB_NAME} ${DIST_DIR}

# create flat lib for ios
if [ -f "install_ios_arm/${LIB_NAME}/lib/libluajit.a" ] ; then
    echo "Creating flat libluajit.a with armv7,arm64,x86_64"
    lipo -create install_ios_arm/${LIB_NAME}/lib/libluajit.a install_ios_arm64/${LIB_NAME}/lib/libluajit.a install_ios_x64/${LIB_NAME}/lib/libluajit.a -output ${DIST_DIR}/prebuilt/ios/libluajit.a
else
    echo "Creating flat libluajit.a with arm64,x86_64"
    lipo -create install_ios_arm64/${LIB_NAME}/lib/libluajit.a install_ios_x64/${LIB_NAME}/lib/libluajit.a -output ${DIST_DIR}/prebuilt/ios/libluajit.a
fi

# check the flat lib
lipo -info ${DIST_DIR}/prebuilt/ios/libluajit.a
