# prepare env
openssl_ver=$(cat source.properties | grep -w 'openssl_ver' | cut -d '=' -f 2 | tr -d ' \n')
openssl_ver=${openssl_ver//./_}
OPENSSL_BUILD_TAG=OpenSSL_$openssl_ver
echo "OPENSSL_BUILD_TAG=$OPENSSL_BUILD_TAG" >> $GITHUB_ENV
ndk_ver=$(cat source.properties | grep -w 'ndk.ver' | cut -d '=' -f 2 | tr -d ' \n')
echo "NDK_VER=$ndk_ver" >> $GITHUB_ENV
openssl_config_options=$(cat source.properties | grep -w 'openssl_config_options_1' | cut -d '=' -f 2 | tr -d '\n')
echo "OPENSSL_CONFIG_OPTIONS_1=$openssl_config_options" >> $GITHUB_ENV
openssl_config_options=$(cat source.properties | grep -w 'openssl_config_options_2' | cut -d '=' -f 2 | tr -d '\n')
echo "OPENSSL_CONFIG_OPTIONS_2=$openssl_config_options" >> $GITHUB_ENV
android_api_level=$(cat source.properties | grep -w 'android_api_level' | cut -d '=' -f 2 | tr -d ' \n')
echo "ANDROID_API_LEVEL=$android_api_level" >> $GITHUB_ENV
android_api_level_arm64=$(cat source.properties | grep -w 'android_api_level_arm64' | cut -d '=' -f 2 | tr -d ' \n')
echo "ANDROID_API_LEVEL_ARM64=$android_api_level_arm64" >> $GITHUB_ENV

# checkout openssl
git clone https://github.com/openssl/openssl.git
pwd
cd openssl 
git checkout $OPENSSL_BUILD_TAG
git submodule update --init --recursive

# config & build
openssl_src_root=`pwd`
openssl_install_dir=$openssl_src_root/$INSTALL_NAME
mkdir $openssl_install_dir
echo OPENSSL_CONFIG_OPTIONS_1=$OPENSSL_CONFIG_OPTIONS_1
echo $OPENSSL_CONFIG_OPTIONS_1 --strict-warnings --prefix=$openssl_install_dir --openssldir=$openssl_install_dir
./Configure $OPENSSL_CONFIG_OPTIONS_1 --strict-warnings --prefix=$openssl_install_dir --openssldir=$openssl_install_dir && perl configdata.pm --dump
make VERBOSE=1
make install
rm -rf $openssl_install_dir/bin
rm -rf $openssl_install_dir/misc
rm -rf $openssl_install_dir/share
