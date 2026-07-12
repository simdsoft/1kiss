$install_dir = $args[0]

if ((Test-Path $install_dir -PathType Container)) {
    Write-Output "Cleaning ${install_dir}..."
    sremove (Join-Path $install_dir 'share')
    sremove (Join-Path $install_dir 'lib/cmake')
    sremove (Join-Path $install_dir 'lib/*.a')
    Get-ChildItem -Path $install_dir -Recurse -File | ForEach-Object { $_.FullName }
}
