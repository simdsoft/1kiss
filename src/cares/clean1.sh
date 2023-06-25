install_dir=$1

if [ -d "$install_dir" ] ; then
    echo "Cleaning ${install_dir}..."
    # Delete files what we don't want
    rm -rf "$install_dir/lib/cmake"
    rm -rf "$install_dir/lib/pkgconfig"
fi
