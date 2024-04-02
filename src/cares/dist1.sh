DIST_ROOT=$1
LIB_NAME=cares
DIST_DIR="${DIST_ROOT}/${LIB_NAME}"

dist_lib ${LIB_NAME} ${DIST_DIR} $DISTF_NATIVES

create_xcfraemwork cares ${LIB_NAME} libcares.a

# overrite ares_build.h with common header
cp -f src/cares/ares_build.h ${DIST_DIR}/include/
