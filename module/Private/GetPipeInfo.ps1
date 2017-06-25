function GetPipeInfo {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string]
        $Pipe
    )
    process {
        if (-not $Pipe) { return }

        $pipeRegex = [regex]::Match($Pipe, 'PSHost\.\d+\.(?<ProcessId>\d+)\.(?<AppDomain>\w+)\.')

        return [PSCustomObject]@{
            PSTypeName = 'BasicPipeInfo'
            ProcessId  = $pipeRegex.Groups['ProcessId'].Value
            AppDomain  = $pipeRegex.Groups['AppDomain'].Value
        }
    }
}