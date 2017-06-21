# SMTP Sender
The sender address vCenter should use when sending emails
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object -Name mail.sender).Value
```

## Remediation Code
```powershell
    Get-AdvancedSetting -Entity $Object -Name mail.sender |
        Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
```
