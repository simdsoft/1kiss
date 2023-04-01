$LIB_ROOT = $args[0]
$angle_ver = $args[1]
$chromeBuildNo = ($angle_ver -split '/')[1]
$chromeVersion = "0.0.0.0"
$fullCommitHash = ''

$chromeRelStr = $(curl -L "https://chromiumdash.appspot.com/fetch_releases?channel=Stable&platform=Windows")
$chromeRelList = $(ConvertFrom-Json -InputObject "$chromeRelStr" -AsHashtable)

foreach($relInfo in $chromeRelList) {
    $ver = $relInfo['version']
    $buildNo = ($ver -split '\.')[2]
    if ($buildNo -eq $chromeBuildNo) {
        if ([System.Version]$ver -gt [System.Version]$chromeVersion) {
            $chromeVersion = $ver
            $fullCommitHash = $relInfo['hashes']['angle'];
        }
    }
}

Out-File -FilePath $LIB_ROOT\bw_version.yml -InputObject "bw_version: $chromeVersion" -Encoding ASCII -Append

echo ${fullCommitHash}
