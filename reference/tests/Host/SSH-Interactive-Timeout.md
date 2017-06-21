# SSH Interactive Timeout
Maximum idle time permitted in an SSH session
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'UserVars.ESXIShellInteractiveTimeout'
    }).Value
```

## Remediation Code
```powershell
    Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'UserVars.ESXIShellInteractiveTimeout'
        } | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
```
