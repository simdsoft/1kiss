$major_ver = $args[0]
$chromeVersion = "$major_ver.0.0.0"
$fullCommitHash = ''

$chromeRelStr = $(Invoke-WebRequest "https://chromiumdash.appspot.com/fetch_releases?channel=Stable&platform=Windows&milestone=$major_ver&num=1")
$chromeRelInfo = $(ConvertFrom-Json -InputObject "$chromeRelStr" -AsHashtable)
if($chromeRelInfo) {
    $chromeVersion = $chromeRelInfo['version']
    $fullCommitHash = $chromeRelInfo['hashes']['angle']
}

return $chromeVersion, $fullCommitHash
