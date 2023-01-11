$install_dir = $args[0]

if ((Test-Path $install_dir -PathType Container)) {
    echo "[windows] Before cleaning ${install_dir}..."
    ls -R "$install_dir\bin"
    ls -R "$install_dir\lib"

    # Delete files what we don't want
    del "$install_dir\html" -recurse
    del "$install_dir\lib\engines-3" -recurse
    # since openssl-3.0.0
    del "$install_dir\lib\ossl-modules" -recurse
    del "$install_dir\bin\*.pl"
    del "$install_dir\bin\*.pdb"
    # del "$install_dir\bin\*.exe"

    echo "[windows] After cleaning ${install_dir}..."
    ls -R "$install_dir\bin"
}
