---
external help file: EditorServicesProcess-help.xml
online version: https://github.com/SeeminglyScience/EditorServicesProcess/blob/master/docs/en-US/Enter-EditorServicesProcess.md
schema: 2.0.0
---

# Enter-EditorServicesProcess

## SYNOPSIS

Enter a new runspace within a process hosted by the PowerShell Editor Services Integrated Console.

## SYNTAX

```powershell
Enter-EditorServicesProcess [[-ProcessId] <Int32>]
```

## DESCRIPTION

The Enter-EditorServicesProcess function creates a new runspace within the integrated console. In this runspace you can interact with Editor Services from a standard PowerShell console.

The runspace will not be the same one the integrated console uses, but it will have a functioning $psEditor variable and contain all the same loaded assemblies.  You can also use the "Get-Runspace" and "Debug-Runspace" cmdlets to interact with the default runspace currently active in the integrated console.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------

```powershell
Enter-EditorServicesProcess
```

Enter the first process found with a instance of the $psEditor editor object.

### -------------------------- EXAMPLE 2 --------------------------

```powershell
Get-EditorServicesProcess *MyProject* | Enter-EditorServicesProcess
```

Enter the first process found with an instance of $psEditor that is also open to a workspace with a path that maches the glob.

### -------------------------- EXAMPLE 3 --------------------------

```powershell
Enter-EditorServicesProcess
$psEditor.GetEditorContext().CurrentFile.InsertText('Testing insert from PowerShell!')
exit
```

Enter the first found Editor Services process, insert text into the currently open file, and exit back to the standard console.

## PARAMETERS

### -ProcessId

Specifies ID of the process to enter.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

## INPUTS

### System.Int32

You can pass process ID's to this function.  If multiple processes are passed, the first will be used and the rest will be ignored.

## OUTPUTS

### None

This function does not return output to the pipeline.

## NOTES

## RELATED LINKS

[Get-EditorServicesProcess](Get-EditorServicesProcess.md)
[Get-Runspace](https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/get-runspace)
[Debug-Runspace](https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/debug-runspace)
