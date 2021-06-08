$install_dir = $args[0]

if ((Test-Path $install_dir -PathType Container)) {
    Write-Output "Cleaning ${install_dir}..."
    # Delete files what we don't want
    Remove-Item "$install_dir\html" -recurse
    Remove-Item "$install_dir\lib\engines-1_1" -recurse
    ls -R "$install_dir\bin"
    Remove-Item "$install_dir\bin\*.pl"
    Remove-Item "$install_dir\bin\*.pdb"
    Remove-Item "$install_dir\bin\*.exe"
    ls -R "$install_dir\bin"
}
