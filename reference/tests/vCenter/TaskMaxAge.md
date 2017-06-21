# TaskMaxAge
Age in days that Tasks will be retained in the vCenter Server Database
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object -Name task.maxAge).Value
```

## Remediation Code
```powershell
    Get-AdvancedSetting -Entity $Object -Name task.maxAge |
        Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
```
