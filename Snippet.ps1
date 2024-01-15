$registry = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" -Recurse
foreach ($a in $registry) {
    ($a | Get-ItemProperty).Psobject.Properties |
    #Exclude powershell-properties in the object
    Where-Object { $_.Name -cnotlike 'PS*' } |
    Select-Object Name, Value
}
