DIST_ROOT=$1
LIB_NAME=opus
DIST_DIR="${DIST_ROOT}/${LIB_NAME}"

dist_lib ${LIB_NAME} ${DIST_DIR} $DISTF_ALL

create_xcfraemwork opus ${LIB_NAME} libopus.a
