DIST_ROOT=$1
LIB_NAME=openssl
DIST_DIR="${DIST_ROOT}/${LIB_NAME}"

dist_lib ${LIB_NAME} ${DIST_DIR} $DISTF_ALL configuration.h config.h.in openssl/

function combine_openssl {
  dir=$1
  libtool -static -o $dir/${LIB_NAME}/lib/libopenssl.a \
    $dir/${LIB_NAME}/lib/libcrypto.a \
    $dir/${LIB_NAME}/lib/libssl.a
}

combine_openssl install_ios_arm64
combine_openssl install_ios_x64
combine_openssl install_ios_arm64_sim
combine_openssl install_tvos_arm64
combine_openssl install_tvos_x64
combine_openssl install_tvos_arm64_sim
combine_openssl install_osx_x64
combine_openssl install_osx_arm64

create_xcfraemwork openssl ${LIB_NAME} libopenssl.a
