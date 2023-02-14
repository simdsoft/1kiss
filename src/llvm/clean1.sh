install_dir=$1

if [ -d "$install_dir" ] ; then
    echo "Cleaning ${install_dir}..."
    if [ "$BUILD_TARGET" = "linux" ] ; then
        rm -f $install_dir/lib/*.so.*
    fi
fi
