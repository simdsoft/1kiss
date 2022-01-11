$install_dir = $args[0]

if ((Test-Path $install_dir -PathType Container)) {
    Write-Output "Cleaning ${install_dir}..."
    # Delete files what we don't want
    Remove-Item "$install_dir\share"
}
