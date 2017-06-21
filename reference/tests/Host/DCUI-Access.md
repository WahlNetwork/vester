# DCUI Access
Comma separated list of users with DCUI access
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'DCUI.Access'
    }).Value
```

## Remediation Code
```powershell
    Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'DCUI.Access'
        } | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
```
