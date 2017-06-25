# The PowerShell Script Analyzer will generate a warning
# diagnostic record for this file due to a bug -
# https://github.com/PowerShell/PSScriptAnalyzer/issues/472
@{
    ExcludeRules = 'PSUseShouldProcessForStateChangingFunctions'
}
