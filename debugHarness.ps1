# Use this file to debug the module.
Import-Module -Name $PSScriptRoot\module\EditorServicesProcess.psd1 -Force

# Uncomment this to break on exceptions.
#Set-PSBreakpoint -Variable StackTrace -Mode Write

# Uncomment and change these to prep editor context.
#$psEditor.Workspace.OpenFile((Join-Path $psEditor.Workspace.Path 'module\Public\Get-EditorServicesProcess.ps1'))
#$psEditor.GetEditorContext().SetSelection(0, 0, 0, 0)

# Place debug code here.
Get-EditorServicesProcess | Enter-EditorServicesProcess
