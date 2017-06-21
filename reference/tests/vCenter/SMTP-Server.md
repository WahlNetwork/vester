# SMTP Server
The server vCenter should use when sending emails
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object -Name mail.smtp.server).Value
```

## Remediation Code
```powershell
    Get-AdvancedSetting -Entity $Object -Name mail.smtp.server |
        Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
```
