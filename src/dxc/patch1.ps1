$lib_src = $args[0]
$cmakelists = Join-Path $lib_src "external/SPIRV-Tools/source/CMakeLists.txt"
if (!(Test-Path $cmakelists)) { return }
$content = Get-Content $cmakelists -Raw

# 1. Remove any pre-existing duplicate targets (upstream bug) and add exactly one
$content = $content -replace 'add_custom_target\(spirv-tools-build-version DEPENDS \$\{SPIRV_TOOLS_BUILD_VERSION_INC\}\)\s*', ''
$content = $content.Replace(
    '   COMMENT "Update build-version.inc in the SPIRV-Tools build directory (if necessary).")',
    '   COMMENT "Update build-version.inc in the SPIRV-Tools build directory (if necessary).")' +
    "`nadd_custom_target(spirv-tools-build-version DEPENDS `${SPIRV_TOOLS_BUILD_VERSION_INC})"
)

# 2. Add the new target to the default dependency chain
$content = $content.Replace(
    'add_dependencies(${target} core_tables extinst_tables)',
    'add_dependencies(${target} core_tables extinst_tables spirv-tools-build-version)'
)

# 3. Remove OBJECT_DEPENDS on software_version.cpp (ordering now via target deps)
$content = $content.Replace(
    "set_source_files_properties(`r`n  `${CMAKE_CURRENT_SOURCE_DIR}/software_version.cpp`r`n  PROPERTIES OBJECT_DEPENDS `"`${SPIRV_TOOLS_BUILD_VERSION_INC}`")",
    "# OBJECT_DEPENDS removed: spirv-tools-build-version target handles ordering for Xcode"
)

Set-Content $cmakelists $content
