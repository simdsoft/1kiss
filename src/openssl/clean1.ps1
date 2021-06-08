$install_dir = $args[0]

if ((Test-Path $install_dir -PathType Container)) {
    echo "[windows] Before cleaning ${install_dir}..."
    ls -R "$install_dir\bin"

    # Delete files what we don't want
    del "$install_dir\html" -recurse
    del "$install_dir\lib\engines-1_1" -recurse
    del "$install_dir\bin\*.pl"
    del "$install_dir\bin\*.pdb"
    del "$install_dir\bin\*.exe"

    echo "[windows] After cleaning ${install_dir}..."
    ls -R "$install_dir\bin"
}
