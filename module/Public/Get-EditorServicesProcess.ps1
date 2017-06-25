function Get-EditorServicesProcess {
    <#
    .EXTERNALHELP EditorServicesProcess-help.xml
    #>
    [CmdletBinding(DefaultParameterSetName='Workspace')]
    param(
        [Parameter(Position=0, ParameterSetName='Workspace')]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string]
        $Workspace = '*',

        [Parameter(Position=0, Mandatory, ParameterSetName='ProcessId')]
        [ValidateNotNullOrEmpty()]
        [int]
        $ProcessId
    )
    end {
        switch ($PSCmdlet.ParameterSetName) {
            ProcessId {
                $runspaceInfo = GetPSESRunspace $ProcessId
                # Always immediate dispose of the runspace here, if they aren't cleaned up properly
                # they will be created in a broken state later.
                $runspaceInfo.Runspace.Dispose()
            }
            Workspace {
                $runspaces = GetPSESRunspace
                $runspaces.Runspace.Dispose()
                $runspaceInfo = $runspaces | Where-Object Workspace -Like $Workspace

            }
        }
        $runspaceInfo | ForEach-Object {
            [PSCustomObject]@{
                PSTypeName = 'EditorServicesProcessInfo'
                ProcessId  = $PSItem.ProcessId
                AppDomain  = $PSItem.AppDomain
                Workspace  = $PSItem.Workspace
            }
        }
    }
}
