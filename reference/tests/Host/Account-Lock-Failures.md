# Account Lock Failures
0 (off) or maximum number of failed logon attempts before the account is locked out
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'Security.AccountLockFailures'
    }).Value
```

## Remediation Code
```powershell
    Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'Security.AccountLockFailures'
        } | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
```
