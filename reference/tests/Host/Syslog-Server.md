# Syslog Server
Syslog server(s) to send log data to
## Discovery Code
```powershell
    Get-VMHostSysLogServer -VMHost $Object
```

## Remediation Code
```powershell
    Set-VMHostSysLogServer -VMHost $Object -SysLogServer $Desired -ErrorAction Stop
    (Get-EsxCli -VMHost $Object).system.syslog.reload()
```
