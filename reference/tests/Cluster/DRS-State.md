# DRS State
On/off switch for Distributed Resource Scheduler (DRS) on the cluster
## Discovery Code
```powershell
    $Object.DRSEnabled
```

## Remediation Code
```powershell
    Set-Cluster -Cluster $Object -DRSEnabled:$Desired -Confirm:$false -ErrorAction Stop
```
