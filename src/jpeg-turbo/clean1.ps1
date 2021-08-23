$install_dir = $args[0]

if ((Test-Path $install_dir -PathType Container)) {
    Write-Output "Cleaning ${install_dir}..."
    # Delete files what we don't want
    # Remove-Item "$install_dir\bin" -recurse
    Remove-Item "$install_dir\share" -recurse
    Remove-Item "$install_dir\lib\cmake" -recurse
    Remove-Item "$install_dir\lib\pkgconfig" -recurse
}
