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
        $Prepare
    )
    end {
        $connection  = [NamedPipeConnectionInfo]::new($TargetProcessId, $TargetAppDomain, $Timeout)
        $typeTable   = [TypeTable]::LoadDefaultTypeFiles()
        $newRunspace = [runspacefactory]::CreateRunspace($connection, $host, $typeTable)

        $null = $newRunspace.GetType().GetProperty('ShouldCloseOnPop', 60).SetValue($newRunspace, $true)

        if ($Prepare.IsPresent) {
            try {
                $newRunspace.Open()
                $psPrepInstance = [powershell]::Create().
                    AddScript('$global:psEditor = (Get-Runspace 2).SessionStateProxy.PSVariable.GetValue(''psEditor'')')
                $psPrepInstance.Runspace = $newRunspace

                $null = $psPrepInstance.Invoke()
            } catch {
                $newRunspace.Close()
                $newRunspace.Dispose()
            } finally {
                if ($psPrepInstance) { $psPrepInstance.Dispose() }
            }
        }
        return $newRunspace
    }
}
