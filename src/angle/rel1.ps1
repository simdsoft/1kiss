$LIB_ROOT = $args[0]
$chromeRelStr = $(curl -L "https://chromiumdash.appspot.com/fetch_releases?channel=Stable&platform=Windows")
$chromeRelList = $(ConvertFrom-Json -InputObject "$chromeRelStr" -AsHashtable)

$chromeLatest = "0.0.0.0"
foreach($relInfo in $chromeRelList) {
    $ver = $relInfo['version']
    if ([System.Version]$ver -gt [System.Version]$chromeLatest) {
        $chromeLatest = $ver
    }
}

Out-File -FilePath $LIB_ROOT\bw_version.yml -InputObject "bw_version: $chromeLatest" -Encoding ASCII -Append
