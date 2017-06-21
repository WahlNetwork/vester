# CD-ROM Host Device
Optionally disallow VMs from using the host CD-ROM drive
## Discovery Code
```powershell
    If (($Object | Get-CDDrive).HostDevice -eq $null) {$false}
    Else {$true}
```

## Remediation Code
```powershell
    If ($Desired -eq $false) {
        $Object | Get-CDDrive | Set-CDDrive -NoMedia -Confirm:$false
    } Else {
        Write-Warning 'CD-ROM tests do not remediate against a desired value of $true'
    }
```
