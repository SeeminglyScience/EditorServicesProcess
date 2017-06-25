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

        # Sometimes when Get-EditorServicesProcess is ran before this, a process or two might be missing
        # for a short time while it's cleaning up.  So we wait.
        $timeoutLoop = 0
        while (-not ($pipeInfo = (GetNamedPipes) -match $targetProcess)) {
            Start-Sleep -Milliseconds 500
            if (($timeoutLoop++) -eq 10) {
                $PSCmdlet.ThrowTerminatingError(
                    [ErrorRecord]::new(
                        [ArgumentException]::new($Strings.CannotFindProcess),
                        'CannotFindProcess',
                        [ErrorCategory]::InvalidArgument,
                        $targetProcess))
            }
        }
        $pipeInfo = $pipeInfo | GetPipeInfo
        $runspace = NewRemoteRunspace $pipeInfo.ProcessId $pipeInfo.AppDomain -Prepare

        if (-not $runspace) {
            $PSCmdlet.ThrowTerminatingError(
                [ErrorRecord]::new(
                    [ArgumentException]::new($Strings.CannotFindProcess),
                    'CannotFindProcess',
                    [ErrorCategory]::InvalidArgument,
                    $targetProcess))
        }

        # If the pipe gets parsed wrong the runspace can come out broken.  Also if cleanup wasn't done
        # currently after exiting the runspace.
        if ('Broken' -eq $runspace.State) {
            $PSCmdlet.ThrowTerminatingError(
                [ErrorRecord]::new(
                    [RuntimeException]::new($Strings.InvalidRunspaceState, $runspace.State.Reason),
                    'InvalidRunspaceState',
                    [ErrorCategory]::InvalidArgument,
                    $targetProcess))
        }
        $ps = [PowerShell]::Create().
            AddScript('
            $global:psEditorRunspace = Get-Runspace 2
            $global:psEditor = $psEditorRunspace.SessionStateProxy.PSVariable.GetValue("psEditor")
            Set-Location $psEditor.Workspace.Path

            Import-Module (Join-Path ($psEditorRunspace.
                SessionStateProxy.
                InvokeCommand.
                GetCommand("Find-Ast", "Function").
                Module.
                ModuleBase) "PowerShellEditorServices.Commands.psd1")
            ')

        try {
            $ps.Runspace = $runspace
            $ps.Invoke()
        } finally {
            $ps.Dispose()
        }
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
