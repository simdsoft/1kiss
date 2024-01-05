$install_dir = $args[0]

if ((Test-Path $install_dir -PathType Container)) {
    Write-Output "Cleaning ${install_dir}..."
    # Delete files what we don't want
    if($IsWindows) {
        Remove-Item "$install_dir\bin\curl-config"
    } else {
        Remove-Item "$install_dir\bin" -Recurse -Force
    }
    Remove-Item "$install_dir\lib\cmake" -Recurse -Force
    Remove-Item "$install_dir\lib\pkgconfig" -Recurse -Force
}
