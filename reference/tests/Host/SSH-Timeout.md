# SSH Timeout
After being enabled, SSH access disables again after this long
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'UserVars.ESXIShellTimeout'
    }).Value
```

## Remediation Code
```powershell
    Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'UserVars.ESXIShellTimeout'
        } | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
```
