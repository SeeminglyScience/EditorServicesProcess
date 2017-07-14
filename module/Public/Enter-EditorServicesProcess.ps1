using namespace System.Management.Automation
using namespace System.Collections.Generic
function Enter-EditorServicesProcess {
    <#
    .EXTERNALHELP EditorServicesProcess-help.xml
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [int]
        $ProcessId
    )
    begin {   $infoList = [List[int]]::new() }
    process { if ($ProcessId) { $infoList.Add($ProcessId) }}
    end {
        if ($infoList) {
            $targetProcess = $infoList[0]
        } else {
            $targetProcess = (Get-EditorServicesProcess)[0].ProcessId
        }

        $runspace = NewRemoteRunspace $targetProcess -Cmdlet $PSCmdlet -Prepare

        # The runspace will close itself on pop, but not dispose, this will take care of that.
        $runspace.add_StateChanged({
            param($Runspace, $RunspaceStateArgs)
            if ('Closed' -eq $RunspaceStateArgs.RunspaceStateInfo.State) {
                $Runspace.Dispose()
            }})
        try {
            $host.PushRunspace($runspace)
        } catch {
            $runspace.Close()
        }
    }
}
