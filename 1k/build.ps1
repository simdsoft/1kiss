$BUILD_TARGET = $args[0]
$BUILD_ARCH = $args[1]
$BUILD_LIBS = $args[2]

$targets_list = @{
    'win32' = $true;
    'winuwp' = $true;
    'ios' = $true;
    'tvos' = $true;
    'osx' = $true;
    'linux' = $true;
    'android' = $true;
}

if (!$targets_list.Contains($BUILD_TARGET)) {
    throw "unsupport build target: $BUILD_TARGET"
}

echo "env:NO_DLL=$env:NO_DLL"

if ($BUILD_ARCH -eq 'amd64_arm64') {
    $BUILD_ARCH = 'arm64'
}

$BUILDWARE_ROOT=(Resolve-Path .\).Path

echo "BUILDWARE_ROOT=$BUILDWARE_ROOT"

$build_script = "$BUILDWARE_ROOT\1k\build1.ps1"
$INSTALL_ROOT="install_${BUILD_TARGET}_${BUILD_ARCH}"

$BUILD_SRC="buildsrc_$BUILD_ARCH"

# Create buildsrc tmp dir for build libs
if(!(Test-Path $BUILD_SRC -PathType Container)) {
    mkdir "$BUILD_SRC"
}

#### install tools
$TOOLS_DIR = "$BUILDWARE_ROOT\tools"
if(!(Test-Path $TOOLS_DIR -PathType Container)) {
    mkdir "$TOOLS_DIR"
}

echo "Before relocate powershell"
powershell -Command {$pwshVSI='PowerShell ' + $PSVersionTable.PSVersion.ToString();echo $pwshVSI}

#relocate powershell.exe to opensource edition pwsh.exe to solve angle gclient execute issues:
# Get-FileHash is not recognized as a name of a cmdlet
$pwshPath = $(Get-Command pwsh).Path
$pwshDir =  Split-Path -Path $pwshPath
Copy-Item "$pwshDir\pwsh.exe" "$pwshDir\powershell.exe" 
$env:Path = "$pwshPath;$env:Path"
echo "After relocate powershell"
powershell -Command {$pwshVSI='PowerShell ' + $PSVersionTable.PSVersion.ToString();echo $pwshVSI}

# Install nasm
$nasm_ver='2.16.01'
$nasm_bin = "$TOOLS_DIR\nasm-$nasm_ver"
if(!(Test-Path "$nasm_bin" -PathType Container)) {
    curl -L "https://www.nasm.us/pub/nasm/releasebuilds/$nasm_ver/win64/nasm-$nasm_ver-win64.zip" -o "$TOOLS_DIR\nasm-$nasm_ver-win64.zip"
    Expand-Archive -Path "$TOOLS_DIR\nasm-$nasm_ver-win64.zip" -DestinationPath "$TOOLS_DIR"
}
$env:Path = "$nasm_bin;$env:Path"
nasm -v

# Install latest cmake for reuqired feature CMAKE_VS_WINDOWS_PLATFORM_MIN_VERSION
$cmake_ver = "3.27.20230315"
$cmake_host = "https://github.com/axmolengine/archive/releases/download/v1.0.0" # "https://github.com/Kitware/CMake/releases/download/v$cmake_ver"
$cmake_bin = "$TOOLS_DIR\cmake-$cmake_ver-windows-x86_64\bin"
if(!(Test-Path "$cmake_bin" -PathType Container)) {
    echo "Downloading $cmake_host/cmake-$cmake_ver-windows-x86_64.zip ..."
    curl -L "$cmake_host/cmake-$cmake_ver-windows-x86_64.zip" -o "$TOOLS_DIR\cmake-$cmake_ver-windows-x86_64.zip"
    Expand-Archive -Path "$TOOLS_DIR\cmake-$cmake_ver-windows-x86_64.zip" -DestinationPath "$TOOLS_DIR\"
}
$env:Path = "$cmake_bin;$env:Path"

cmake --version

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
    $BUILD_LIBS = "zlib,openssl,cares,curl,jpeg-turbo,luajit,angle"
}

$BUILD_LIBS = $BUILD_LIBS -split ","

Foreach ($libname in $BUILD_LIBS) {
    Write-Output "Building $libname ..."
    Invoke-Expression -Command "$build_script $libname $BUILD_TARGET $BUILD_ARCH $INSTALL_ROOT"
}

# Export INSTALL_ROOT for uploading
Write-Output "INSTALL_ROOT=$INSTALL_ROOT" >> ${env:GITHUB_ENV}
