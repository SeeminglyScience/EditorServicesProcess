#requires -Module InvokeBuild, PSScriptAnalyzer, Pester, PlatyPS, PSStringTemplate -Version 5.1
[CmdletBinding()]
param()

$script:ProjectRoot   = $PSScriptRoot
$script:ProjectName   = $script:ProjectRoot | Split-Path -Leaf
$script:Manifest      = Test-ModuleManifest -Path $script:ProjectRoot\module\$script:ProjectName.psd1 -ErrorAction 0 -WarningAction 0
$script:Version       = $script:Manifest.Version
$script:ReleaseFolder = "$script:ProjectRoot\Release\$script:ProjectName\$script:Version"
$script:ManifestPath  = "$script:ReleaseFolder\$script:ProjectName.psd1"
$script:Locale        = $PSCulture
$script:PesterCCPath  = "$script:ReleaseFolder\*.psm1", "$script:ReleaseFolder\Public\*.ps1", "$script:ReleaseFolder\Private\*.ps1"

task Clean -Before BuildDocs {
    if (Test-Path $script:ProjectRoot\Release) {
        Remove-Item $script:ProjectRoot\Release -Recurse
    }
    $null = New-Item $script:ReleaseFolder -ItemType Directory
}

task BuildDocs -Before Build {
    $null = New-ExternalHelp -Path        $script:ProjectRoot\docs\$script:Locale `
                             -OutputPath "$script:ReleaseFolder\$script:Locale"
}

task Build -Before Test, Analyze {
    Copy-Item $script:ProjectRoot\module\* -Destination $script:ReleaseFolder -Recurse -Force
}

task Analyze -Before Install {
    Invoke-ScriptAnalyzer -Path          $script:ReleaseFolder `
                          -Settings      $script:ProjectRoot\ScriptAnalyzerSettings.psd1 `
                          -Recurse
}

task Test -If {$false} -Before Install {
    Invoke-Pester -CodeCoverage $script:PesterCCPath -PesterOption @{ IncludeVSCodeMarker = $true }
}

task Install {
    $installBase = $Home
    if ($profile) { $installBase = $profile | Split-Path }
    $installPath = Join-Path $installBase -ChildPath 'Modules'

    if (-not (Test-Path $installPath)) {
        $null = New-Item $installPath -ItemType Directory
    }

    Copy-Item $script:ProjectRoot\Release\* -Destination $installPath -Force -Recurse
}

task Publish {
    if (-not (Test-Path $env:USERPROFILE\.PSGallery\apikey.xml)) {
        throw 'Could not find PSGallery API key!'
    }

    $apiKey = (Import-Clixml $env:USERPROFILE\.PSGallery\apikey.xml).GetNetworkCredential().Password
    Publish-Module -Name $script:ReleaseFolder -NuGetApiKey $apiKey -Confirm
}

task . Build
