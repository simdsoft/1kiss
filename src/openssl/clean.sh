$install_dir=$1

if [ -d "$install_dir" ] ; then
    echo "Cleaning ${install_dir}..."
    rm -rf $install_dir/bin
    rm -rf $install_dir/misc
    rm -rf $install_dir/share
fi
