DIST_REVISION=$1
DIST_SUFFIX=$2
DIST_LIBS=$3

DIST_NAME=buildware_dist

if [ "${DIST_REVISION}" != "" ]; then
    DIST_NAME="${DIST_NAME}_${DIST_REVISION}"
fi

if [ "${DIST_SUFFIX}" != "" ]; then
    DIST_NAME="${DIST_NAME}${DIST_SUFFIX}"
fi

DIST_NOTES=`pwd`/verlist.txt

DIST_ROOT=`pwd`/${DIST_NAME}
mkdir -p $DIST_ROOT

DIST_VERLIST=$DIST_ROOT/verlist.yml

# compile copy1k for script, non-recursive simple wildchard without error support
mkdir -p build
g++ -std=c++17 1k/copy1k.cpp -o build/copy1k
PATH=`pwd`/build:$PATH

# The dist flags
DISTF_WIN=1
DISTF_UWP=2
DISTF_WINALL=$(($DISTF_WIN|$DISTF_UWP))
DISTF_LINUX=4
DISTF_ANDROID=8
DISTF_MAC=16
DISTF_IOS=32
DISTF_TVOS=64
DISTF_APPL=$(($DISTF_MAC|$DISTF_IOS|$DISTF_TVOS))
DISTF_NO_INC=1024
DISTF_NO_UWP=$(($DISTF_WIN|$DISTF_LINUX|$DISTF_ANDROID|$DISTF_APPL))
DISTF_ALL=$(($DISTF_WINALL|$DISTF_LINUX|$DISTF_ANDROID|$DISTF_APPL))

function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s/\r$//" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) >= 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

function dist_lib {
    LIB_NAME=$1
    DIST_DIR=$2
    DIST_FLAGS=$3
    CONF_HEADER=$4 # [optional]
    CONF_TEMPLATE=$5 # [optional]
    INC_DIR=$6 # [optional] such as: openssl/

    if [ $(($DIST_FLAGS & $DISTF_NO_INC)) = 0 ]; then
        # mkdir for commen
        mkdir -p ${DIST_DIR}/include

        # mkdir for platform spec config header file
        if [ "$CONF_TEMPLATE" = "config.h.in" ] ; then
            mkdir -p ${DIST_DIR}/include/win32/${INC_DIR}
            mkdir -p ${DIST_DIR}/include/win64/${INC_DIR}
            mkdir -p ${DIST_DIR}/include/linux/${INC_DIR}
            mkdir -p ${DIST_DIR}/include/mac/${INC_DIR}
            # mkdir -p ${DIST_DIR}/include/ios-arm/${INC_DIR}
            mkdir -p ${DIST_DIR}/include/ios-arm64/${INC_DIR}
            mkdir -p ${DIST_DIR}/include/ios-x64/${INC_DIR}
            mkdir -p ${DIST_DIR}/include/tvos-arm64/${INC_DIR}
            mkdir -p ${DIST_DIR}/include/tvos-x64/${INC_DIR}
            mkdir -p ${DIST_DIR}/include/android-arm/${INC_DIR}
            mkdir -p ${DIST_DIR}/include/android-arm64/${INC_DIR}
            mkdir -p ${DIST_DIR}/include/android-x86/${INC_DIR}
            mkdir -p ${DIST_DIR}/include/android-x86_64/${INC_DIR}
        elif [ "$CONF_TEMPLATE" = "config_ab.h.in" ] ; then
            mkdir -p ${DIST_DIR}/include/win32/${INC_DIR}
            mkdir -p ${DIST_DIR}/include/unix/${INC_DIR}
        fi

        # copy common headers
        if [ ! $(($DIST_FLAGS & $DISTF_MAC)) = 0 ]; then
            cp -rf install_osx_x64/${LIB_NAME}/include/${INC_DIR} ${DIST_DIR}/include/${INC_DIR}
        elif [ ! $(($DIST_FLAGS & $DISTF_WINALL)) = 0 ]; then
            cp -rf install_win_x64/${LIB_NAME}/include/${INC_DIR} ${DIST_DIR}/include/${INC_DIR}
        fi

        if [ "$CONF_HEADER" != "" ] ; then
            rm -rf ${DIST_DIR}/include/${INC_DIR}${CONF_HEADER}

            CONF_CONTENT=$(cat 1k/$CONF_TEMPLATE)
            STYLED_LIB_NAME=${LIB_NAME//-/_}
            CONF_CONTENT=${CONF_CONTENT//@LIB_NAME@/$STYLED_LIB_NAME}
            CONF_CONTENT=${CONF_CONTENT//@INC_DIR@/$INC_DIR}
            CONF_CONTENT=${CONF_CONTENT//@CONF_HEADER@/$CONF_HEADER}
            echo "$CONF_CONTENT" >> ${DIST_DIR}/include/${INC_DIR}${CONF_HEADER}

            # copy platform spec config header file
            if [ "$CONF_TEMPLATE" = "config.h.in" ] ; then
                cp install_win_x86/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/win32/${INC_DIR}
                cp install_win_x64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/win64/${INC_DIR}
                cp install_linux_x64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/linux/${INC_DIR}
                cp install_osx_x64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/mac/${INC_DIR}
                # cp install_ios_arm/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/ios-arm/${INC_DIR}
                cp install_ios_arm64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/ios-arm64/${INC_DIR}
                cp install_ios_x64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/ios-x64/${INC_DIR}
                cp install_tvos_arm64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/tvos-arm64/${INC_DIR}
                cp install_tvos_x64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/tvos-x64/${INC_DIR}
                cp install_android_arm/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/android-arm/${INC_DIR}
                cp install_android_arm64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/android-arm64/${INC_DIR}
                cp install_android_x86/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/android-x86/${INC_DIR}
                cp install_android_x64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/android-x86_64/${INC_DIR}

            elif [ "$CONF_TEMPLATE" = "config_ab.h.in" ] ; then
                cp install_win_x86/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/win32/${INC_DIR}
                cp install_linux_x64/${LIB_NAME}/include/${INC_DIR}${CONF_HEADER} ${DIST_DIR}/include/unix/${INC_DIR}
            fi
        fi
    fi

    # create prebuilt dirs
    if [ ! $(($DIST_FLAGS & $DISTF_WIN)) = 0 ]; then
        mkdir -p ${DIST_DIR}/prebuilt/win/x86
        copy1k "install_win_x86/${LIB_NAME}/lib/*.lib" ${DIST_DIR}/prebuilt/win/x86/
        copy1k "install_win_x86/${LIB_NAME}/bin/*.dll" ${DIST_DIR}/prebuilt/win/x86/

        mkdir -p ${DIST_DIR}/prebuilt/win/x64
        copy1k "install_win_x64/${LIB_NAME}/lib/*.lib" ${DIST_DIR}/prebuilt/win/x64/
        copy1k "install_win_x64/${LIB_NAME}/bin/*.dll" ${DIST_DIR}/prebuilt/win/x64/
    fi

    if [ ! $(($DIST_FLAGS & $DISTF_UWP)) = 0 ]; then
        mkdir -p ${DIST_DIR}/prebuilt/uwp/x64
        copy1k "install_uwp_x64/${LIB_NAME}/lib/*.lib" ${DIST_DIR}/prebuilt/uwp/x64/
        copy1k "install_uwp_x64/${LIB_NAME}/bin/*.dll" ${DIST_DIR}/prebuilt/uwp/x64/

        mkdir -p ${DIST_DIR}/prebuilt/uwp/arm64
        copy1k "install_uwp_arm64/${LIB_NAME}/lib/*.lib" ${DIST_DIR}/prebuilt/uwp/arm64/
        copy1k "install_uwp_arm64/${LIB_NAME}/bin/*.dll" ${DIST_DIR}/prebuilt/uwp/arm64/
    fi

    if [ ! $(($DIST_FLAGS & $DISTF_LINUX)) = 0 ]; then
        mkdir -p ${DIST_DIR}/prebuilt/linux
        copy1k "install_linux_x64/${LIB_NAME}/lib/*.a" ${DIST_DIR}/prebuilt/linux/
        copy1k "install_linux_x64/${LIB_NAME}/lib/*.so" ${DIST_DIR}/prebuilt/linux/
    fi

    if [ ! $(($DIST_FLAGS & $DISTF_ANDROID)) = 0 ]; then
        mkdir -p ${DIST_DIR}/prebuilt/android/armeabi-v7a
        mkdir -p ${DIST_DIR}/prebuilt/android/arm64-v8a
        mkdir -p ${DIST_DIR}/prebuilt/android/x86
        mkdir -p ${DIST_DIR}/prebuilt/android/x86_64
        cp install_android_arm/${LIB_NAME}/lib/*.a ${DIST_DIR}/prebuilt/android/armeabi-v7a/
        cp install_android_arm64/${LIB_NAME}/lib/*.a ${DIST_DIR}/prebuilt/android/arm64-v8a/
        cp install_android_x86/${LIB_NAME}/lib/*.a ${DIST_DIR}/prebuilt/android/x86/
        cp install_android_x64/${LIB_NAME}/lib/*.a ${DIST_DIR}/prebuilt/android/x86_64/
    fi

    if [ ! $(($DIST_FLAGS & $DISTF_MAC)) = 0 ]; then
        mkdir -p ${DIST_DIR}/prebuilt/mac
    fi

    if [ ! $(($DIST_FLAGS & $DISTF_IOS)) = 0 ]; then
        mkdir -p ${DIST_DIR}/prebuilt/ios
    fi

    if [ ! $(($DIST_FLAGS & $DISTF_TVOS)) = 0 ]; then
        mkdir -p ${DIST_DIR}/prebuilt/tvos
    fi

    bw_branch=
    bw_commit_hash=
    bw_commit_count=
    bw_version=
    verinfo_file=
    ver=
    
    if [ -f "install_win_x64/${LIB_NAME}/bw_version.yml" ] ; then
        verinfo_file="install_win_x64/${LIB_NAME}/bw_version.yml"
    elif [ -f "install_osx_x64/${LIB_NAME}/bw_version.yml" ] ; then
        verinfo_file="install_osx_x64/${LIB_NAME}/bw_version.yml"
    elif [ -f "install_linux_x64/${LIB_NAME}/bw_version.yml" ] ; then
        verinfo_file="install_linux_x64/${LIB_NAME}/bw_version.yml"
    fi

    echo "verinfo_file=$verinfo_file"

    if [ "$verinfo_file" != "" ] ; then
        eval $(parse_yaml "$verinfo_file")
        if [ "$bw_version" != "" ] ; then
            echo "$LIB_NAME: $bw_version" >> "$DIST_VERLIST"
            echo "- $LIB_NAME: $bw_version" >> "$DIST_NOTES"
        else
           if [ "$bw_branch" != "" ] && [ "$bw_branch" != "master" ] ; then
               eval $(parse_yaml "src/${LIB_NAME}/build.yml")
               if [ "$ver" != "" ] ; then
                  echo "$LIB_NAME: $ver-$bw_commit_hash" >> "$DIST_VERLIST"
                  echo "- $LIB_NAME: $ver-$bw_commit_hash" >> "$DIST_NOTES"
               else
                  echo "$LIB_NAME: $bw_branch-$bw_commit_hash" >> "$DIST_VERLIST"
                  echo "- $LIB_NAME: $bw_branch-$bw_commit_hash" >> "$DIST_NOTES"
               fi
           else
               echo "$LIB_NAME: git $bw_commit_hash" >> "$DIST_VERLIST"
               echo "- $LIB_NAME: git $bw_commit_hash" >> "$DIST_NOTES"
           fi
        fi
    else
        # read version from src/${LIB_NAME}/build.yml
        eval $(parse_yaml "src/${LIB_NAME}/build.yml")
        echo "$LIB_NAME: $ver" >> "$DIST_VERLIST"
        echo "- $LIB_NAME: $ver" >> "$DIST_NOTES"
    fi
}

# dist libs
if [ "$DIST_LIBS" = "" ] ; then
    DIST_LIBS="zlib,jpeg-turbo,openssl,curl,luajit,angle,glsl-optimizer"
fi

if [ -f "$DIST_VERLIST" ] ; then
    rm -f "$DIST_VERLIST"
fi

libs_arr=(${DIST_LIBS//,/ })
libs_count=${#libs_arr[@]}
echo "Dist $libs_count libs ..."
mkdir ./seprate
for (( i=0; i<${libs_count}; ++i )); do
  lib_name=${libs_arr[$i]}
  source src/$lib_name/dist1.sh $DIST_ROOT
  zip -q -r ./seprate/$lib_name.zip ${DIST_NAME}/$lib_name
done

ls ./seprate/

# create dist package
DIST_PACKAGE=${DIST_NAME}.zip
zip -q -r ${DIST_PACKAGE} ${DIST_NAME}

# Export DIST_NAME & DIST_PACKAGE for uploading
if [ "$GITHUB_ENV" != "" ] ; then
    echo "DIST_NAME=$DIST_NAME" >> $GITHUB_ENV
    echo "DIST_PACKAGE=${DIST_PACKAGE}" >> $GITHUB_ENV
    echo "DIST_NOTES=${DIST_NOTES}" >> $GITHUB_ENV
    echo "DIST_VERLIST=${DIST_VERLIST}" >> $GITHUB_ENV
fi
