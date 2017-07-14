# EditorServicesProcess

The EditorServicesProcess module allows you to enter a runspace in the integrated console of a PowerShell Editor Services editor from outside the integrated console.  From this runspace you can interact with the `$psEditor` editor object and all of the functions from the Commands module such as `Find-Ast`, `Set-ScriptExtent`, etc.

## Installation

### Gallery

```powershell
Install-Module EditorServicesProcess -Scope CurrentUser
```

### Source

#### VSCode

- `git clone 'https://github.com/SeeminglyScience/EditorServicesProcess.git'`
- Open EditorServicesProcess in VSCode
- Run task `Install`

#### PowerShell

```powershell
git clone 'https://github.com/SeeminglyScience/EditorServicesProcess.git'
Set-Location .\EditorServicesProcess
Invoke-Build -Task Install
```

## Usage

### Entering

```powershell
# Enter the first process that is open to a workspace with a matching path
Get-EditorServicesProcess -Workspace *MyProject* | Enter-EditorServicesProcess

# Or enter a specific process
Enter-EditorServicesProcess -ProcessId 32412
```

### Interacting

```powershell
# Use the $psEditor object
$psEditor.GetEditorContext().SelectedRange

# Or any of the functions from the Commands module
Find-Ast { $_.VariablePath.UserPath -eq '_' } | Set-ScriptExtent -Text '$PSItem'

# Get variables from the main runspace (psEditorRunspace variable is created by this module)
$psEditorRunspace.SessionStateProxy.PSVariable.GetValue('myVarName')

# Even debug the main runspace (YMMV, you fight with PSES for control)
Debug-Runspace $psEditorRunspace
```

### Returning

```powershell
exit
```

## TODO

1. ~~Add function to invoke a scriptblock in the main runspace.~~ Done.
