DIST_ROOT=$1
LIB_NAME=openssl
DIST_DIR="${DIST_ROOT}/${LIB_NAME}"

dist_lib ${LIB_NAME} ${DIST_DIR} $DISTF_ALL configuration.h config.h.in openssl/
create_xcfraemwork ossl-ssl ${LIB_NAME} libssl.a
create_xcfraemwork ossl-crypto ${LIB_NAME} libcrypto.a
