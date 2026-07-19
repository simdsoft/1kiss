DIST_ROOT=$1
LIB_NAME=llvm
DIST_DIR="${DIST_ROOT}/${LIB_NAME}"

dist_lib ${LIB_NAME} ${DIST_DIR} $(($DISTF_WIN32|$DISTF_LINUX|$DISTF_MAC|$DISTF_NO_INC))

# make fat libclang.dylib for mac
LIB_FILE=libclang.dylib
mkdir -p fat_tmp/${LIB_NAME}/lib/mac/
lipo -create install_osx_arm64/${LIB_NAME}/lib/$LIB_FILE install_osx_x64/${LIB_NAME}/lib/$LIB_FILE -output fat_tmp/${LIB_NAME}/lib/mac/$LIB_FILE
lipo -info fat_tmp/${LIB_NAME}/lib/mac/$LIB_FILE

mkdir -p ${DIST_DIR}/lib/mac/
copy1k fat_tmp/${LIB_NAME}/lib/mac/$LIB_FILE ${DIST_DIR}/lib/mac/
rm -rf ${DIST_DIR}/lib/win32/x86

# dist clang-format binaries
BIN_NAME=clang-format
BIN_DIR=${DIST_DIR}/bin

copy1k "install_win32_x64/${LIB_NAME}/bin/${BIN_NAME}.exe" ${BIN_DIR}/win32/x64/

mkdir -p ${BIN_DIR}/linux/x64
copy1k "install_linux_x64/${LIB_NAME}/bin/${BIN_NAME}" ${BIN_DIR}/linux/x64/
mkdir -p ${BIN_DIR}/linux/arm64
copy1k "install_linux_arm64/${LIB_NAME}/bin/${BIN_NAME}" ${BIN_DIR}/linux/arm64/

mkdir -p fat_tmp/${LIB_NAME}/bin/
lipo -create install_osx_arm64/${LIB_NAME}/bin/$BIN_NAME install_osx_x64/${LIB_NAME}/bin/$BIN_NAME -output fat_tmp/${LIB_NAME}/bin/$BIN_NAME
lipo -info fat_tmp/${LIB_NAME}/bin/$BIN_NAME

mkdir -p ${BIN_DIR}/mac/
copy1k fat_tmp/${LIB_NAME}/bin/$BIN_NAME ${BIN_DIR}/mac/
