
if [[ ! "$ndk_ver" == "" ]] && [[ $ndk_ver > '21' ]] ; then
    script_dir=$1
    lib_src_dir=$2
    echo "LuaJIT: patching makefile for build on ndk-r22+ ..."

    cp -f $script_dir/Makefile $lib_src_dir/src/
fi
