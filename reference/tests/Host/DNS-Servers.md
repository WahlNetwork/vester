# DNS Servers
DNS address(es) for the host to query against
## Discovery Code
```powershell
    (Get-VMHostNetwork -VMHost $Object).DnsAddress
```

## Remediation Code
```powershell
    Get-VMHostNetwork -VMHost $Object | Set-VMHostNetwork -DnsAddress $Desired -ErrorAction Stop
```
