# Disk MaxLUN
Highest LUN ID available to ESXi host.  Above this number will be ignored.
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'Disk.MaxLUN'
    }).Value
```

## Remediation Code
```powershell
    Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'Disk.MaxLUN'
        } | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
```
