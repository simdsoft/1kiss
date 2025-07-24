#!/usr/bin/env pwsh
param(
  $action = '',
  $ver = 19
)

$ver = [int]$ver

function find_clang() {
  $verStr = $(. clang --version 2>$null) | Select-Object -First 1
  $matchInfo = [Regex]::Match($verStr, '(\d+\.)+(\*|\d+)(\-[a-z0-9]+)?')
  $foundVer = $matchInfo.Value
  return $foundVer
}

# install
if ($action -eq 'install') {
  $clang_cmd = Get-Command "clang-$ver" -ErrorAction SilentlyContinue
  if (!$clang_cmd) {
    echo "Installing llvm-$ver ..."
    wget https://apt.llvm.org/llvm.sh
    chmod +x llvm.sh
    sudo ./llvm.sh $ver
  }
}

# active
if ($action -eq 'active' -or $action -eq 'install') {
  echo "Activating llvm-$ver ..."

  # config installed llvm to alternatives
  $priority = $ver * 10
  sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-$ver $priority
  sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-$ver $priority
  sudo update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb-$ver $priority

  # list available llvm versions
  sudo update-alternatives --display clang

  $actived_ver = [Version]$(find_clang)

  if ($actived_ver.Major -ne $ver) {
    # force set llvm to the specific version
    echo "Forcing switch actived llvm $($actived_ver.Major) => $ver ..."
    sudo update-alternatives --set clang /usr/bin/clang-$ver
    sudo update-alternatives --set clang++ /usr/bin/clang++-$ver
    sudo update-alternatives --set lldb /usr/bin/lldb-$ver

    $actived_ver = [Version]$(find_clang)
  }

  # check result llvm version
  $clang_cmd = Get-Command "clang" -ErrorAction SilentlyContinue
  echo "Activated llvm-clang: $($clang_cmd.Source), version: $actived_ver"
} 
else {
  &clang-$ver --version
}
