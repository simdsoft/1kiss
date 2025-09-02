# 
# NOTES:
# since chromium/5941, angle contains submodules
# latest chromium/7258, require use_custom_libcxx=false on msvc
#
$major_ver = $args[0]
$chromeVersion = "$major_ver.0.0.0"
$fullCommitHash = ''

$chromeRelStr = $(Invoke-WebRequest "https://chromiumdash.appspot.com/fetch_releases?channel=Stable&platform=Windows&milestone=$major_ver&num=1")
$chromeRelInfo = $(ConvertFrom-Json -InputObject "$chromeRelStr" -AsHashtable)
if($chromeRelInfo) {
    $chromeVersion = $chromeRelInfo['version']
    $fullCommitHash = $chromeRelInfo['hashes']['angle']
    Write-Host "chrome version: $chromeVersion, angle head ref: $fullCommitHash"
}

return $chromeVersion, $fullCommitHash
