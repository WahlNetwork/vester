# DCUI Timeout
0 (off) number of seconds before the DCUI timeout occurs
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'UserVars.DcuiTimeOut'
    }).Value
```

## Remediation Code
```powershell
    Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'UserVars.DcuiTimeOut'
        } | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
```
