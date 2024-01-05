$lib_src = $args[0]

Copy-Item -Path "$PSScriptRoot\build\*" -Destination "$lib_src\build" -Recurse -Force
Copy-Item -Path "$PSScriptRoot\src\*" -Destination "$lib_src\src" -Recurse -Force
