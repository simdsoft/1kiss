$LIB_ROOT = $args[0]

Copy-Item -Path "$PSScriptRoot\build\*" -Destination "$LIB_ROOT\build" -Recurse -Force
