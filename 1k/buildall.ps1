$BUILD_TARGET = 'windows'
$BUILD_ARCH = $args[0]

$BUILDWARE_ROOT=(Resolve-Path .\).Path
$build_script = "$BUILDWARE_ROOT\1k\build.ps1"
$INSTALL_ROOT="install_${BUILD_TARGET}_${BUILD_ARCH}"

# Create buildsrc tmp dir for build libs
if(!(Test-Path buildsrc -PathType Container)) {
    mkdir "buildsrc"
}

# Install nasm
$nasm_bin = "$BUILDWARE_ROOT\buildsrc\nasm-2.15.05"
if(!(Test-Path "$nasm_bin" -PathType Container)) {
    curl https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/win64/nasm-2.15.05-win64.zip -o .\buildsrc\nasm-2.15.05-win64.zip
    Expand-Archive -Path .\buildsrc\nasm-2.15.05-win64.zip -DestinationPath .\buildsrc
}
$env:Path = "$nasm_bin;$env:Path"
nasm -v

Install-Module -Name powershell-yaml -Force -Repository PSGallery -Scope CurrentUser

# Build libs
Invoke-Expression -Command "$build_script jpeg-turbo $ARCH $INSTALL_ROOT"
Invoke-Expression -Command "$build_script openssl $ARCH $INSTALL_ROOT"

# Export INSTALL_ROOT for uploading
Write-Output "INSTALL_ROOT=$INSTALL_ROOT" >> ${env:GITHUB_ENV}
