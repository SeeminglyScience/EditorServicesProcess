Import-LocalizedData -BindingVariable Strings -FileName Strings -ErrorAction Ignore

Get-ChildItem $PSScriptRoot\Private\*, $PSScriptRoot\Public\* -Include *.ps1 | ForEach-Object {
    . $PSItem.FullName
}

Export-ModuleMember -Function *-*