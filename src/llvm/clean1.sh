install_dir=$1

if [ -d "$install_dir" ] ; then
    echo "Cleaning ${install_dir}..."
    rm -rf $install_dir/bin
    rm -rf $install_dir/misc
    rm -rf $install_dir/share
    if [ "$BUILD_TARGET" = "linux" ] ; then
        mv $install_dir/lib64 $install_dir/lib
    fi

    if [ "$BUILD_TARGET" = "linux" ] || [ "$BUILD_TARGET" = "osx" ] ; then
        rm -rf $install_dir/lib/ossl-modules
    fi
fi
