DIST_ROOT=$1
LIB_NAME=openssl
DIST_DIR="${DIST_ROOT}/${LIB_NAME}"

dist_lib ${LIB_NAME} ${DIST_DIR} $DISTF_ALL configuration.h config.h.in openssl/

create_fat ${LIB_NAME} libssl.a
create_fat ${LIB_NAME} libcrypto.a

xcodebuild -create-xcframework \
    -library install_ios_arm64/${LIB_NAME}/lib/libssl.a \
    -library fat_tmp/${LIB_NAME}/lib/ios_sim/libssl.a \
    -library install_tvos_arm64/${LIB_NAME}/lib/libssl.a \
    -library fat_tmp/${LIB_NAME}/lib/tvos_sim/libssl.a \
    -library fat_tmp/${LIB_NAME}/lib/mac/libssl.a \
    -library install_ios_arm64/${LIB_NAME}/lib/libcrypto.a \
    -library fat_tmp/${LIB_NAME}/lib/ios_sim/libcrypto.a \
    -library install_tvos_arm64/${LIB_NAME}/lib/libcrypto.a \
    -library fat_tmp/${LIB_NAME}/lib/tvos_sim/libcrypto.a \
    -library fat_tmp/${LIB_NAME}/lib/mac/libcrypto.a \
    -output ${DIST_DIR}/lib/ios/$NAME.xcframework
