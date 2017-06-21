# DNS Search Domains
Domain(s) to append to DNS queries
## Discovery Code
```powershell
    (Get-VMHostNetwork -VMHost $Object).SearchDomain
```

## Remediation Code
```powershell
    Get-VMHostNetwork -VMHost $Object | Set-VMHostNetwork -SearchDomain $Desired -ErrorAction Stop
```
