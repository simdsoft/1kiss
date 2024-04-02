DIST_ROOT=$1
LIB_NAME=zlib
DIST_DIR="${DIST_ROOT}/${LIB_NAME}"

dist_lib ${LIB_NAME} ${DIST_DIR} $DISTF_NATIVES

create_xcfraemwork zlib ${LIB_NAME} libz.a

# overrite zconf.h with common header
cp -f src/zlib/zconf.h ${DIST_DIR}/include/
