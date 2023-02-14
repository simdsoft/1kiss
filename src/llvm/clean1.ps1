$install_dir = $args[0]

if ((Test-Path $install_dir -PathType Container)) {
    echo "[windows] Cleaning ${install_dir}..."
    ls -R "$install_dir"
}
