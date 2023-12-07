DIST_ROOT=$1
LIB_NAME=llvm
DIST_DIR="${DIST_ROOT}/${LIB_NAME}"

dist_lib ${LIB_NAME} ${DIST_DIR} $(($DISTF_WIN32|$DISTF_LINUX|$DISTF_MAC|$DISTF_NO_INC))


copy1k install_osx_x64/${LIB_NAME}/lib/libclang.dylib ${DIST_DIR}/lib/mac/
