using namespace System.Management.Automation.Runspaces

function GetPSESRunspace {
    [CmdletBinding()]
    param($procId)
    end {
        $namedPipes = GetNamedPipes | Where-Object { $PSItem -match 'PSHost.*powershell' }

        if ($procId) {
            $namedPipes = $namedPipes.Where{ $PSItem.Contains($procId) }
        }

        foreach ($pipe in $namedPipes) {

            $pipeInfo = GetPipeInfo $pipe

            if ($pipeInfo.ProcessId -and $pipeInfo.ProcessId -eq $pid) { continue }
            
            if ($procId -and $procId -ne $pipeInfo.ProcessId) { continue }

            $runspace = NewRemoteRunspace $pipeInfo.ProcessId $pipeInfo.AppDomain
            try {
                $runspace.Open()
                $powerShell = [powershell]::Create().
                    AddScript('(Get-Runspace 2).SessionStateProxy.PSVariable.GetValue(''psEditor'').Workspace.Path')

                $powerShell.Runspace = $runspace
                $workspacePath = $powerShell.Invoke()
            } catch {
                $runspace.Close()
            } finally {
                if ($powerShell) { $powerShell.Dispose() }
            }

            if ($workspacePath) {
                [PSCustomObject]@{
                    ProcessId = $pipeInfo.ProcessId
                    AppDomain = $pipeInfo.AppDomain
                    Runspace  = $runspace
                    Workspace = $workspacePath
                }
            } else {
                $runspace.Dispose()
            }
        }
    }
}
