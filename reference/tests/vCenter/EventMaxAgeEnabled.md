# EventMaxAgeEnabled
Enables Event cleanup and enforces the max age defined in EventMaxAge
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object -Name event.maxAgeEnabled).Value
```

## Remediation Code
```powershell
    Get-AdvancedSetting -Entity $Object -Name event.maxAgeEnabled |
        Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
```
