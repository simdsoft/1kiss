# query sdk name by xcode version
$xcode_sdks_map = @{
    'osx'     = 
    @{
        '13.1.0' = '12.0'
        '13.2.1' = '12.1'
        '13.3.1' = '12.3'
        '13.4.0' = '12.3'
        '13.4.1' = '12.3'
        '14.0.1' = '12.3'
        '14.1.0' = '13.0'
        '14.2.0' = '13.1'
        '14.3.1' = '13.3'
        '15.0.1' = '14.0'
        '15.1.0' = '14.2'
    }
    
    'ios'     =
    @{
        '13.1.0' = '15.0'
        '13.2.1' = '15.2'
        '13.3.1' = '15.4'
        '13.4.0' = '15.5'
        '13.4.1' = '15.5'
        '14.0.1' = '16.0'
        '14.1.0' = '16.1'
        '14.2.0' = '16.2'
        '14.3.1' = '16.4'
        '15.0.1' = '17.0'
        '15.1.0' = '17.2'
    }
    'tvos'    =
    @{
        '13.1.0' = '15.0'
        '13.2.1' = '15.2'
        '13.3.1' = '15.4'
        '13.4.0' = '15.4'
        '13.4.1' = '15.4'
        '14.0.1' = '16.0'
        '14.1.0' = '16.1'
        '14.2.0' = '16.1'
        '14.3.1' = '16.4'
        '15.0.1' = '17.0'
        '15.1.0' = '17.2'
    }
    'watchos' = 
    @{
        '13.1.0' = '8.0'
        '13.2.1' = '8.3'
        '13.3.1' = '8.5'
        '13.4.1' = '8.5'
        '14.0.1' = '9.0'
        '14.1.0' = '9.1'
        '14.2.0' = '9.1'
        '14.3.1' = '9.4'
        '15.0.1' = '10.0'
        '15.1.0' = '10.2'
    }
};

function xcode_get_sdkname($xcode_ver, $target, $simulator = $false) {
    $xcode_ver_nums = $xcode_ver.Split('.')
    if ($xcode_ver_nums.Count -lt 3) {
        $xcode_ver += '.0'
    }
    $target_sdks = $xcode_sdks_map[$target]
    if ($target_sdks) {
        $sdk_ver = $target_sdks[$xcode_ver]
        if ($sdk_ver) {
            switch ($target) {
                'osx' { Write-Output "macosx$sdk_ver" }
                'ios' { Write-Output "$(@('iphoneos', 'iphonesimulator')[$simulator])$sdk_ver" }
                'tvos' { Write-Output "$(@('appletvos', 'appletvsimulator')[$simulator])$sdk_ver" }
                'watchos' { Write-Output "$(@('watchos', 'watchsimulator')[$simulator])$sdk_ver" }
            }
        }
    }
}
