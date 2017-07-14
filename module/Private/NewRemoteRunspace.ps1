using namespace System.Management.Automation.Runspaces

function NewRemoteRunspace {
    [OutputType([System.Management.Automation.Runspaces.Runspace])]
    [CmdletBinding()]
    param(
        [int]
        $TargetProcessId,

        [string]
        $TargetAppDomain,

        [int]
        $Timeout = 10,

        [switch]
        $Prepare,

        [System.Management.Automation.PSCmdlet]
        $Cmdlet
    )
    end {
        if (-not $TargetAppDomain) {
            # Sometimes when Get-EditorServicesProcess is ran before this, a process or two might be missing
            # for a short time while it's cleaning up.  So we wait.
            $timeoutLoop = 0
            while (-not ($pipeInfo = (GetNamedPipes) -match $TargetProcessId)) {
                Start-Sleep -Milliseconds 500
                if (($timeoutLoop++) -eq 10) {
                    $Cmdlet.ThrowTerminatingError(
                        [ErrorRecord]::new(
                            [ArgumentException]::new($Strings.CannotFindProcess),
                            'CannotFindProcess',
                            [ErrorCategory]::InvalidArgument,
                            $TargetProcessId))
                }
            }
            $TargetAppDomain = $pipeInfo | GetPipeInfo | ForEach-Object AppDomain
        }
        $connection  = [NamedPipeConnectionInfo]::new($TargetProcessId, $TargetAppDomain, $Timeout)
        $typeTable   = [TypeTable]::LoadDefaultTypeFiles()
        $newRunspace = [runspacefactory]::CreateRunspace($connection, $host, $typeTable)

        if (-not $newRunspace) {
            $Cmdlet.ThrowTerminatingError(
                [ErrorRecord]::new(
                    [ArgumentException]::new($Strings.CannotFindProcess),
                    'CannotFindProcess',
                    [ErrorCategory]::InvalidArgument,
                    $TargetProcessId))
        }

        $null = $newRunspace.GetType().GetProperty('ShouldCloseOnPop', 60).SetValue($newRunspace, $true)

        if ($Prepare.IsPresent) {
            try {
                $newRunspace.Open()
                $psPrepInstance = [powershell]::Create().
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
                $psPrepInstance.Runspace = $newRunspace

                $null = $psPrepInstance.Invoke()
            } catch {
                $newRunspace.Close()
                $newRunspace.Dispose()
            } finally {
                if ($psPrepInstance) { $psPrepInstance.Dispose() }
            }
        }

        # If the pipe gets parsed wrong the runspace can come out broken.  Also if cleanup wasn't done
        # currently after exiting the runspace.
        if ('Broken' -eq $newRunspace.State) {
            $Cmdlet.ThrowTerminatingError(
                [ErrorRecord]::new(
                    [RuntimeException]::new($Strings.InvalidRunspaceState, $newRunspace.State.Reason),
                    'InvalidRunspaceState',
                    [ErrorCategory]::InvalidArgument,
                    $TargetProcessId))
        }
        return $newRunspace
    }
}
