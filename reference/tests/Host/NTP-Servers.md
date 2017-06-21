# NTP Servers
Server(s) to use for synchronizing the host's clock
## Discovery Code
```powershell
    Get-VMHostNtpServer -VMHost $Object
```

## Remediation Code
```powershell
    Get-VMHostNtpServer -VMHost $Object | ForEach-Object -Process {
        Remove-VMHostNtpServer -VMHost $Object -NtpServer $_ -Confirm:$false -ErrorAction Stop
    }
    Add-VMHostNtpServer -VMHost $Object -NtpServer $Desired -ErrorAction Stop
    $ntpclient = Get-VMHostService -VMHost $Object | Where-Object -FilterScript {
        $_.Key -match 'ntpd'
    }
    $ntpclient | Set-VMHostService -Policy:On -Confirm:$false -ErrorAction:Stop
    $ntpclient | Restart-VMHostService -Confirm:$false -ErrorAction:Stop
```
