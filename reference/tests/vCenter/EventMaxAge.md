# EventMaxAge
Age in days that Events will be retained in the vCenter Server Database
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object -Name event.maxAge).Value
```

## Remediation Code
```powershell
    Get-AdvancedSetting -Entity $Object -Name event.maxAge |
        Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
```
