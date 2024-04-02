DIST_ROOT=$1
LIB_NAME=luajit
DIST_DIR="${DIST_ROOT}/${LIB_NAME}"

dist_lib ${LIB_NAME} ${DIST_DIR} $DISTF_NO_WINRT

create_xcfraemwork luajit ${LIB_NAME} libluajit.a
