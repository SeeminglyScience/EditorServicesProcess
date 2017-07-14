---
external help file: EditorServicesProcess-help.xml
online version: https://github.com/SeeminglyScience/EditorServicesProcess/docs/en-US/Invoke-EditorServicesProcess.md
schema: 2.0.0
---

# Invoke-EditorServicesProcess

## SYNOPSIS

Invoke a script block in the default runspace of processes hosted by the PowerShell Editor Services Integrated Console.

## SYNTAX

```powershell
Invoke-EditorServicesProcess [[-ScriptBlock] <ScriptBlock>] [[-ProcessId] <Int32>]
```

## DESCRIPTION

The Invoke-EditorServicesProcess allows you to invoke a script in the default runspace of any process hosted by the PowerShell Editor Services Integrated Console.

This is similar to the Enter-EditorServicesProcess function, with a few differences.

- It can be ran on any number of processes

- Invocation will take place in the default runspace of the Integrated Console, instead of a proxy runspace for the process.

- It can be ran interactively.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------

```powershell
$processes = Get-EditorServicesProcess
$processes | Invoke-EditorServicesProcess {
    $psEditor.Workspace.ShowInformationMessage('Hey there!')
}
```

Shows a information message on all editor services windows.

### -------------------------- EXAMPLE 2 --------------------------

```powershell
Get-EditorServicesProcess -Workspace '${workspaceRoot}' |
    Invoke-EditorServicesProcess { Invoke-Build -Task Build }
```

Invoke a VSCode task in the context of the Integrated Console.

### -------------------------- EXAMPLE 3 --------------------------

```powershell
code .
Get-EditorServicesProcess -Workspace $pwd |
    Invoke-EditorServicesProcess { psedit (Get-ChildItem *.ps1) }
```

Start VSCode in the current directory and open all *.ps1 files.

## PARAMETERS

### -ScriptBlock

Specifies the script block to invoke.

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProcessId

Specifies the process ID(s) of the Integrated Console(s).

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

## INPUTS

### System.Int32

You can pipe Process ID's to this function, or objects with a property named "ProcessId"

## OUTPUTS

### System.Object

This function will return any object returned by the specified scriptblock, though it will be
deserialized.

## NOTES

## RELATED LINKS

[Enter-EditorServicesProcess](Enter-EditorServicesProcess.md)

[Get-EditorServicesProcess](Get-EditorServicesProcess.md)
