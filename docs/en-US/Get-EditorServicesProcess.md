---
external help file: EditorServicesProcess-help.xml
online version: https://github.com/SeeminglyScience/EditorServicesProcess/blob/master/docs/en-US/Get-EditorServicesProcess.md
schema: 2.0.0
---

# Get-EditorServicesProcess

## SYNOPSIS

Gets processes running PowerShell EditorServices.

## SYNTAX

### Workspace (Default)

```powershell
Get-EditorServicesProcess [[-Workspace] <String>]
```

### ProcessId

```powershell
Get-EditorServicesProcess [-ProcessId] <Int32>
```

## DESCRIPTION

The Get-EditorServicesProcess function gets processes currently running on the system that are hosted within the PowerShell Editor Services Integrated Terminal. The returned object contains the process ID, AppDomain name, and current workspace path.  This object can also be used with other functions in this module to manipulate the processes.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------

```powershell
Get-EditorServicesProcess
```

Returns all current instances of the integrated terminal.

### -------------------------- EXAMPLE 2 --------------------------

```powershell
Get-EditorServicesProcess -Workspace *Projects*MyProject*
```

Returns only instances that are open to a workspace that matches the specified pattern.

### -------------------------- EXAMPLE 3 --------------------------

```powershell
Get-EditorServicesProcess -ProcessId 23145 | Enter-EditorServicesProcess
```

Enters the process with an ID of 23145 if it is within the integrated terminal.

## PARAMETERS

### -Workspace

Specifies a workspace path that the process must have open to be returned.  This parameter accepts wildcards.

```yaml
Type: String
Parameter Sets: Workspace
Aliases:

Required: False
Position: 1
Default value: *
Accept pipeline input: False
Accept wildcard characters: True
```

### -ProcessId

Specifies the ID of the process to return.

```yaml
Type: Int32
Parameter Sets: ProcessId
Aliases:

Required: True
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### None

This function does not accept input from the pipeline.

## OUTPUTS

### PSCustomObject

This function returns a PSCustomObject for each process found that matches the criteria. This object has the properties "ProcessId", "AppDomain", and "Workspace".

## NOTES

## RELATED LINKS

[Enter-EditorServicesProcess](Enter-EditorServicesProcess.md)
