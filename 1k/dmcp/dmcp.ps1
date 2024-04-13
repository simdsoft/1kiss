param(
    $cc,
    $cflags
)

$IsWin = $IsWindows -or ("$env:OS" -eq 'Windows_NT')

echo "cflags=${cflags}"

$cflags = $cflags.Split(' ')

if($cc.EndsWith('cl.exe')) {
    # vs2019+ support: 
    &$cc /EP /Zc:preprocessor /PD $cflags (Join-Path $PSScriptRoot 'dummy.c')
} else {
    echo ''| &$cc -E -dM $cflags -
}
