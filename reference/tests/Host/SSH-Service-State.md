# SSH Service State
On/off switch for allowing SSH connections to the host
## Discovery Code
```powershell
    ($Object | Get-VMHostService | Where-Object -FilterScript {
        $_.Key -eq 'TSM-SSH'
    }).Running
```

## Remediation Code
```powershell
    if ($Desired -eq $true) 
    {
        Start-VMHostService -HostService ($Object |
            Get-VMHostService |
            Where-Object -FilterScript {
                $_.Key -eq 'TSM-SSH'
        }) -ErrorAction Stop -Confirm:$false
    }
    if ($Desired -eq $false) 
    {
        Stop-VMHostService -HostService ($Object |
            Get-VMHostService |
            Where-Object -FilterScript {
                $_.Key -eq 'TSM-SSH'
        }) -ErrorAction Stop -Confirm:$false
    }
```
