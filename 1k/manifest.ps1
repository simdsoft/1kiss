# Default manifest, refer in build1k.ps1
# For maintaining axmol, halx99 contributed some PRs to https://gitlab.kitware.com/cmake
# 3.27.0: https://gitlab.kitware.com/cmake/cmake/-/merge_requests/8319
# 3.28.0: https://gitlab.kitware.com/cmake/cmake/-/merge_requests/8632
#         https://gitlab.kitware.com/cmake/cmake/-/merge_requests/9008
# 3.28.0: https://gitlab.kitware.com/cmake/cmake/-/merge_requests/9014
#

if ($IsWindows) {
    $manifest['nasm'] = '2.16.01+'
} else {
    $manifest['nasm'] = '2.15.05+'
}

# [void]$manifest
