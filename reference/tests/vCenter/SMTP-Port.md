# SMTP Port
The port vCenter should use when sending emails
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object -Name mail.smtp.port).Value
```

## Remediation Code
```powershell
    Get-AdvancedSetting -Entity $Object -Name mail.smtp.port |
        Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
```
