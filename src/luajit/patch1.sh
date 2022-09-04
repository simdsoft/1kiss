if [[ ! "$ndk_ver" == "" ]] && [[ $ndk_ver > '21' ]] ; then
    script_dir=$1
    lib_src_dir=$2
    echo "LuaJIT: patching makefile for build on ndk-r22+ ..."

    cp -f $script_dir/ndk/Makefile $lib_src_dir/src/
fi

if [[ "$BUILD_TARGET" == "ios" ]] ; then
    script_dir=$1
    lib_src_dir=$2
    echo "LuaJIT: patching makefile for build on iOS ..."

    cp -f $script_dir/apple/Makefile $lib_src_dir/src/
fi

if [[ "$BUILD_TARGET" == "tvos" ]] ; then
    script_dir=$1
    lib_src_dir=$2
    echo "LuaJIT: patching makefile for build on tvOS ..."

    cp -f $script_dir/apple/Makefile $lib_src_dir/src/
fi

if [[ "$BUILD_TARGET" == "watchos" ]] ; then
    script_dir=$1
    lib_src_dir=$2
    echo "LuaJIT: patching makefile for build on watchOS ..."

    cp -f $script_dir/apple/Makefile $lib_src_dir/src/
fi
