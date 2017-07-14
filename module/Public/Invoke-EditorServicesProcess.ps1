function Invoke-EditorServicesProcess {
    <#
    .EXTERNALHELP EditorServicesProcess-help.xml
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [ValidateNotNullOrEmpty()]
        [scriptblock]
        $ScriptBlock,

        [Parameter(Position=1, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [int]
        $ProcessId
    )
    process {
        try {
            $runspace = NewRemoteRunspace $ProcessId -Cmdlet $PSCmdlet
            $runspace.Open()
            $ps = [powershell]::Create()
            $ps.Runspace = $runspace
            $ps.AddScript('
                try {{
                    $runspace = (Get-Runspace 2)
                    $ps = [powershell]::Create()
                    $ps.Runspace = $runspace
                    $ps.AddScript(''{0}'').
                        Invoke()
                }} finally {{
                    if ($ps) {{ $ps.Dispose() }}
                }}
                ' -f $ScriptBlock.ToString()).
                Invoke()
        } finally {
            if ($runspace) { $runspace.Dispose() }
            if ($ps) { $ps.Dispose() }
        }
    }
}
