# SSH Warning
On/off switch for the vSphere warning when a host has SSH enabled
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'UserVars.SuppressShellWarning'
    }).Value
```

## Remediation Code
```powershell
    Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'UserVars.SuppressShellWarning'
        } | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
```
