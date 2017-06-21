# NTP Service Policy
Policy for NTP service (on,off,automatic)
## Discovery Code
```powershell
    ($Object | Get-VMHostService | Where-Object -FilterScript {
        $_.Key -eq 'ntpd'
    }).Policy
```

## Remediation Code
```powershell
   Set-VMHostService -HostService ($Object |
            Get-VMHostService |
            Where-Object -FilterScript {
                $_.Key -eq 'ntpd'
        }) -Policy $Desired -ErrorAction Stop
```
