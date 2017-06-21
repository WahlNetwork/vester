# TaskMaxAgeEnabled
Enables Task cleanup and enforces the max age defined in TaskMaxAge
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object -Name task.maxAgeEnabled).Value
```

## Remediation Code
```powershell
    Get-AdvancedSetting -Entity $Object -Name task.maxAgeEnabled |
        Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
```
