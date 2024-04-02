DIST_ROOT=$1
LIB_NAME=jpeg-turbo
DIST_DIR="${DIST_ROOT}/${LIB_NAME}"

dist_lib ${LIB_NAME} ${DIST_DIR} $DISTF_NO_WINRT jconfig.h config_ab.h.in

create_xcfraemwork jpeg ${LIB_NAME} libjpeg.a
