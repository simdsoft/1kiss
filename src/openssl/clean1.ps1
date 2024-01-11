$install_dir = $args[0]

if ((Test-Path $install_dir -PathType Container)) {
    echo "[windows] Before cleaning ${install_dir}..."
    if ($IsWindows) {
        ls -R "$install_dir\bin"
        ls -R "$install_dir\lib"

        # Delete files what we don't want
        # del "$install_dir\html" -recurse
        del "$install_dir\lib\engines-3" -recurse
        # since openssl-3.0.0
        del "$install_dir\lib\ossl-modules" -recurse
        del "$install_dir\bin\*.pl"
        del "$install_dir\bin\*.pdb"
        # del "$install_dir\bin\*.exe"

        echo "[windows] After cleaning ${install_dir}..."
        ls -R "$install_dir\bin"
    } else {
        rm -rf $install_dir/bin
        rm -rf $install_dir/misc
        rm -rf $install_dir/share
        if ($TARGET_OS -eq "linux") {
            mv $install_dir/lib64 $install_dir/lib
        }
        elseif($Global:is_wasm) {
            mv "$install_dir/libx32" "$install_dir/lib"
        }

        rm -rf "$install_dir/lib/engines-3"
        rm -rf "$install_dir/lib/ossl-modules"
        rm -rf "$install_dir/lib/pkgconfig"
    }
}
