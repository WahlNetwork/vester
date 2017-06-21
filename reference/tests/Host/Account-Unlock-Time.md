# Account Unlock Time
0 (off) or number of seconds that an account is locked out
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'Security.AccountUnlockTime'
    }).Value
```

## Remediation Code
```powershell
    Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'Security.AccountUnlockTime'
        } | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
```
