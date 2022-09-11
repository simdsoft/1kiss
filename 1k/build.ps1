$BUILD_TARGET = $args[0]
$BUILD_ARCH = $args[1]
$BUILD_LIBS = $args[2]

echo "env:NO_DLL=$env:NO_DLL"

$BUILDWARE_ROOT=(Resolve-Path .\).Path
$build_script = "$BUILDWARE_ROOT\1k\build1.ps1"
$INSTALL_ROOT="install_${BUILD_TARGET}_${BUILD_ARCH}"

$BUILD_SRC="buildsrc_$BUILD_ARCH"

# Create buildsrc tmp dir for build libs
if(!(Test-Path $BUILD_SRC -PathType Container)) {
    mkdir "$BUILD_SRC"
}

# Install nasm
$nasm_bin = "$BUILDWARE_ROOT\$BUILD_SRC\nasm-2.15.05"
if(!(Test-Path "$nasm_bin" -PathType Container)) {
    curl https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/win64/nasm-2.15.05-win64.zip -o .\$BUILD_SRC\nasm-2.15.05-win64.zip
    Expand-Archive -Path .\$BUILD_SRC\nasm-2.15.05-win64.zip -DestinationPath .\$BUILD_SRC
}
$env:Path = "$nasm_bin;$env:Path"
nasm -v

# winbuild only

function FindVSPath {
    $vs_versions = "2022", "2019"
    $vs_roots = "$env:ProgramFiles\Microsoft Visual Studio", "$env:ProgramFiles (x86)\Microsoft Visual Studio"
    $vs_editions = "Enterprise", "Professional", "Community", "Preview"

    Foreach($vs_root in $vs_roots) {  
        Foreach($vs_version in $vs_versions) {
            Foreach($vs_edition in $vs_editions) {
                $vs_path = "$vs_root\$vs_version\$vs_edition"
                if(Test-Path "$vs_path" -PathType Container) {
                    return $vs_path
                }
            }
        }
    }
    
    return $null
}

$use_msvcr14x = $null
[bool]::TryParse($env:use_msvcr14x, [ref]$use_msvcr14x)

if ($IsWindows -And $use_msvcr14x) {
   $vs_path = FindVSPath
   if ($vs_path -ne $null) {
       # cmd /k ""$vs_path\VC\Auxiliary\Build\vcvarsall.bat" $BUILD_ARCH"
       
       if ("$env:LIB" -eq "") {
           Import-Module "$vs_path\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
           Enter-VsDevShell -VsInstanceId a55efc1d -SkipAutomaticLocation -DevCmdArguments "-arch=$BUILD_ARCH -no_logo"
       }
       
       if ("$env:LIB".IndexOf('msvcr14x') -eq -1) {
           $msvcr14x_root = $env:msvcr14x_ROOT
           $env:Platform = $BUILD_ARCH
           Invoke-Expression -Command "$msvcr14x_root\msvcr14x_nmake.ps1"
       }
       
       echo "LIB=$env:LIB"
   }
}

if ((Get-Module -ListAvailable -Name powershell-yaml) -eq $null) {
    Install-Module -Name powershell-yaml -Force -Repository PSGallery -Scope CurrentUser
}

if ("$BUILD_LIBS" -eq "") {
    $BUILD_LIBS = "angle"
}

$BUILD_LIBS = $BUILD_LIBS -split ";"

Foreach ($libname in $BUILD_LIBS) {
    Write-Output "Building $libname ..."
    Invoke-Expression -Command "$build_script $libname $BUILD_ARCH $INSTALL_ROOT"
}

# Export INSTALL_ROOT for uploading
Write-Output "INSTALL_ROOT=$INSTALL_ROOT" >> ${env:GITHUB_ENV}
