# Space Utilization Threshold Percent
Specifies the maximum percentage of consumed space allowed before Storage DRS is triggered for the datastore cluster
## Discovery Code
```powershell
    $Object.SpaceUtilizationThresholdPercent
```

## Remediation Code
```powershell
    Set-DatastoreCluster -DatastoreCluster $Object -SpaceUtilizationThresholdPercent $Desired -Confirm:$FALSE -ErrorAction Stop
```
