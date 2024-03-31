function xcode_get_sdkname($xcode_ver, $target, $simulator = $false) {
    $xcode_ver_nums = $xcode_ver.Split('.')
    if ($xcode_ver_nums.Count -lt 3) {
        $xcode_ver += '.0'
    }
    $sdk_name = $null
    switch ($target) {
        'osx' { $sdk_name = "macosx" }
        'ios' { $sdk_name = "$(@('iphoneos', 'iphonesimulator')[$simulator])" }
        'tvos' { $sdk_name = "$(@('appletvos', 'appletvsimulator')[$simulator])" }
        'watchos' { $sdk_name = "$(@('watchos', 'watchsimulator')[$simulator])" }
    }
    if ($sdk_name) {
        $sdk_ver = xcodebuild -version -sdk $sdk_name SDKVersion
        return "$sdk_name$sdk_ver"
    } else {
        throw "can't find sdk for target $target"
    }
}
