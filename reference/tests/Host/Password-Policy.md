# Password Policy
pam_passwdqc Password Policy. Default = retry=3 min=disabled,disabled,disabled,7,7
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'Security.PasswordQualityControl'
    }).Value
```

## Remediation Code
```powershell
    Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'Security.PasswordQualityControl'
        } | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
```
