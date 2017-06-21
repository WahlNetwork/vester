# IO Load Balance Enabled
Specifies whether I/O load balancing is enabled for the datastore cluster
## Discovery Code
```powershell
    $Object.IOLoadBalanceEnabled
```

## Remediation Code
```powershell
    Set-DatastoreCluster -DatastoreCluster $Object -IOLoadBalanceEnabled $Desired -Confirm:$FALSE -ErrorAction Stop
```
