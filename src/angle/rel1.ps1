$LIB_ROOT = $args[0]
$milestone = $args[1]
$chromeVersion = "$milestone.0.0.0"
$fullCommitHash = ''

$chromeRelStr = $(curl -L "https://chromiumdash.appspot.com/fetch_releases?channel=Stable&platform=Windows&milestone=$milestone&num=1")
$chromeRelInfo = $(ConvertFrom-Json -InputObject "$chromeRelStr" -AsHashtable)
if($chromeRelInfo) {
    $chromeVersion = $chromeRelInfo['version']
    $fullCommitHash = $chromeRelInfo['hashes']['angle']
}

Out-File -FilePath $LIB_ROOT\bw_version.yml -InputObject "bw_version: $chromeVersion" -Encoding ASCII -Append

return ${fullCommitHash}
