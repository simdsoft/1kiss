$install_dir = $args[0]

if ((Test-Path $install_dir -PathType Container)) {
    Write-Output "Cleaning ${install_dir}..."
    # Delete files what we don't want
    # Remove-Item "$install_dir\bin" -recurse
    sremove "$install_dir\share"
    sremove "$install_dir\lib\cmake"
    sremove "$install_dir\lib\pkgconfig"
    ls -R "$install_dir"
}
