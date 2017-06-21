# NTP Service State
Checks state of NTP service (running or stopped)
## Discovery Code
```powershell
    ($Object | Get-VMHostService | Where-Object -FilterScript {
        $_.Key -eq 'ntpd'
    }).Running
```

## Remediation Code
```powershell
    if ($Desired -eq $true) 
    {
        Start-VMHostService -HostService ($Object |
            Get-VMHostService |
            Where-Object -FilterScript {
                $_.Key -eq 'ntpd'
        }) -ErrorAction Stop -Confirm:$false
    }
    if ($Desired -eq $false) 
    {
        Stop-VMHostService -HostService ($Object |
            Get-VMHostService |
            Where-Object -FilterScript {
                $_.Key -eq 'ntpd'
        }) -ErrorAction Stop -Confirm:$false
    }
```
