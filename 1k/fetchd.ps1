# fetch repo directly
param(
    $url,
    $version,
    $prefix,
    $revision = $null
)

# content of _1kiss with yaml format
# ver: 1.0
# branch: 1.x
# commits: 2802
# rev: 29b0b28

Set-Alias println Write-Host

$cache_dir = Join-Path (Resolve-Path $PSScriptRoot/..).Path 'cache'

if (!(Test-Path $cache_dir -PathType Container)) {
    mkdir $cache_dir
}

if (!$url -or !$prefix) {
    throw 'fetch.ps1: missing parameters'
}

function download_file($url, $out) {
    if (Test-Path $out -PathType Leaf) { return }
    println "Downloading $url to $out ..."
    Invoke-WebRequest -Uri $url -OutFile $out
}

function mkdirs($path) {
    if (!(Test-Path $path -PathType Container)) {
        New-Item $path -ItemType Directory 1>$null
    }
}

$folder_name = (Split-Path $url -leafbase)
if ($folder_name.EndsWith('.tar')) {
    $folder_name = $folder_name.Substring(0, $folder_name.length - 4)
}
$lib_src = Join-Path $prefix $folder_name

function download_repo($url, $out) {
    if (!$url.EndsWith('.git')) {
        download_file $url $out
        if ($out.EndsWith('.zip')) {
            Expand-Archive -Path $out -DestinationPath $prefix
        }
        elseif ($out.EndsWith('.tar.gz')) {
            tar xf "$out" -C $prefix
        }
    }
    else {
        git clone $url $lib_src
        if (!(Test-Path $(Join-Path $lib_src '.git')) -and (Test-Path $lib_src -PathType Container)) {
            Remove-Item $lib_src -Recurse -Force 
        }
    }
}

$is_git_repo = $url.EndsWith('.git')
$sentry = Join-Path $lib_src '_1kiss'

$is_rev_modified = $false
# if sentry file missing, re-clone
if (!(Test-Path $sentry -PathType Leaf)) {
    if (Test-Path $lib_src -PathType Container) {
        Remove-Item $lib_src -Recurse -Force
    }

    if ($url.EndsWith('.tar.gz')) {
        $out_file = Join-Path $cache_dir "${folder_name}.tar.gz"
    }
    elseif ($url.EndsWith('.zip')) {
        $out_file = Join-Path $cache_dir "${folder_name}.zip"
    } else {
        $out_file = $null
    }

    download_repo -url $url -out $out_file
    
    if (Test-Path $lib_src -PathType Container) {
        New-Item $sentry -ItemType File
        $is_rev_modified = $true
    }
    else {
        throw "fetch.ps1: fetch content from $url failed"
    }
}

# checkout revision for git repo
if ($is_git_repo) {
    $old_rev_hash = $(git -C $lib_src rev-parse HEAD)

    git -C $lib_src checkout $revision 1>$null 2>$null

    $new_rev_hash = $(git -C $lib_src rev-parse HEAD)

    if(!$is_rev_modified) {
        $is_rev_modified = $old_rev_hash -ne $new_rev_hash
    }
}

if ($is_rev_modified) {
    $branch_name = $(git -C $lib_src branch --show-current)
    $sentry_content = "ver: $version"
    if ($branch_name) {
        git pull
        $commits = $(git -C $lib_src rev-list --count HEAD)
        $sentry_content += "`nbranch: $branch_name"
        $sentry_content += "`ncommits: $commits"

        # track branch change revision to latest short commit hash of branch
        $revision = $(git -C $lib_src rev-parse --short=7 HEAD)
    }
    if ($version -ne $revision) {
        $sentry_content += "`nrev: $revision"
    }
    [System.IO.File]::WriteAllText($sentry, $sentry_content)
}

if (Test-Path (Join-Path $lib_src '.gn') -PathType Leaf) {
    # the repo use google gn build system manage deps and build
    Push-Location $lib_src
    if (Test-Path 'scripts/bootstrap.py' -PathType Leaf) {
        python scripts/bootstrap.py
    }
    gclient sync -D
    Pop-Location
}
