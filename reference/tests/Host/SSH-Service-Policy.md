# SSH Service Policy
Policy for SSH service (on,off,automatic)
## Discovery Code
```powershell
    ($Object | Get-VMHostService | Where-Object -FilterScript {
        $_.Key -eq 'TSM-SSH'
    }).Policy
```

## Remediation Code
```powershell
    Set-VMHostService -HostService ($Object |
            Get-VMHostService |
            Where-Object -FilterScript {
                $_.Key -eq 'TSM-SSH'
        }) -Policy $Desired -ErrorAction Stop
```
