# Default manifest, refer in 1k/1kiss.ps1

if ($IsWin) {
    $manifest['nasm'] = '3.01+'
} else {
    $manifest['nasm'] = '2.15.05+'
}

# since 3.1.60+, the llvm-19 compiling class template more strict
$manifest['emsdk'] = '3.1.72+'
$manifest['cmake'] = '3.29.3~3.31.5+'
# Keep accepting installed Ninja 1.10+, but download a release with ARM64 binaries.
$manifest['ninja'] = '1.10.0~1.13.2+'
$manifest['msvc'] = '14.42+'
