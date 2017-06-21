# DRS Automation Level
Automation Level for Distributed Resource Scheduler (DRS) on the cluster
## Discovery Code
```powershell
    $Object.DRSAutomationLevel
```

## Remediation Code
```powershell
    Set-Cluster -Cluster $Object -DRSAutomationLevel:$Desired -Confirm:$false -ErrorAction Stop
```
