$LIB_ROOT = $args[0]
$chromeRelStr = $(curl -L "https://chromiumdash.appspot.com/fetch_releases?channel=Stable&platform=Windows&num=1")
$chromeRelInfo = $(ConvertFrom-Json -InputObject "$chromeRelStr" -AsHashtable)
$chromeVersion = $chromeRelInfo.version
Out-File -FilePath $LIB_ROOT\bw_version.txt -InputObject "bw_version: $chromeVersion" -Encoding ASCII -Append
