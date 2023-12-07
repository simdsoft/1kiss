DIST_ROOT=$1
LIB_NAME=luajit
DIST_DIR="${DIST_ROOT}/${LIB_NAME}"

dist_lib ${LIB_NAME} ${DIST_DIR} $DISTF_NO_WINRT

# create flat lib for ios
if [ -f "install_ios_arm/${LIB_NAME}/lib/libluajit.a" ] ; then
    echo "Creating flat libluajit.a with armv7,arm64,x86_64"
    lipo -create install_ios_arm/${LIB_NAME}/lib/libluajit.a install_ios_arm64/${LIB_NAME}/lib/libluajit.a install_ios_x64/${LIB_NAME}/lib/libluajit.a -output ${DIST_DIR}/lib/ios/libluajit.a
else
    echo "Creating flat libluajit.a with arm64,x86_64"
    lipo -create install_ios_arm64/${LIB_NAME}/lib/libluajit.a install_ios_x64/${LIB_NAME}/lib/libluajit.a -output ${DIST_DIR}/lib/ios/libluajit.a
fi

# create flat lib for tvos
if [ -f "install_tvos_arm/${LIB_NAME}/lib/libluajit.a" ] ; then
    echo "Creating flat libluajit.a with armv7,arm64,x86_64"
    lipo -create install_tvos_arm/${LIB_NAME}/lib/libluajit.a install_tvos_arm64/${LIB_NAME}/lib/libluajit.a install_tvos_x64/${LIB_NAME}/lib/libluajit.a -output ${DIST_DIR}/lib/tvos/libluajit.a
else
    echo "Creating flat libluajit.a with arm64,x86_64"
    lipo -create install_tvos_arm64/${LIB_NAME}/lib/libluajit.a install_tvos_x64/${LIB_NAME}/lib/libluajit.a -output ${DIST_DIR}/lib/tvos/libluajit.a
fi

# create fat lib for mac
lipo -create install_osx_arm64/${LIB_NAME}/lib/libluajit.a install_osx_x64/${LIB_NAME}/lib/libluajit.a -output ${DIST_DIR}/lib/mac/libluajit.a

# check the fat lib
lipo -info ${DIST_DIR}/lib/mac/libluajit.a

