$lib_src = $args[0]
$ver = $args[1]

$patch_src = "$PSScriptRoot\$ver"

if (Test-Path $patch_src -PathType Container) {
  Write-Host "Apply patch $patch_src to $lib_src for version: $ver"
  Copy-Item -Path "$PSScriptRoot\$ver\build\*" -Destination "$lib_src\build" -Recurse -Force
  Copy-Item -Path "$PSScriptRoot\$ver\src\*" -Destination "$lib_src\src" -Recurse -Force
}
else {
  Write-Host "No patch for version: $ver"
}
