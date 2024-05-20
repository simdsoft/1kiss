DIST_ROOT=$1
LIB_NAME=llvm
DIST_DIR="${DIST_ROOT}/${LIB_NAME}"

dist_lib ${LIB_NAME} ${DIST_DIR} $(($DISTF_WIN32|$DISTF_LINUX|$DISTF_MAC|$DISTF_NO_INC))

$LIB_FILE = 'libclang.dylib'
mkdir -p fat_tmp/${LIB_NAME}/lib/mac/
lipo -create install_osx_arm64/${LIB_NAME}/lib/$LIB_FILE install_osx_x64/${LIB_NAME}/lib/$LIB_FILE -output fat_tmp/${LIB_NAME}/lib/mac/$LIB_FILE
lipo -info fat_tmp/${LIB_NAME}/lib/mac/$LIB_FILE

copy1k fat_tmp/${LIB_NAME}/mac/$LIB_FILE ${DIST_DIR}/lib/mac/
