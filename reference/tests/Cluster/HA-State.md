# HA State
On/off switch for High Availability on the cluster
## Discovery Code
```powershell
    $Object.HAEnabled
```

## Remediation Code
```powershell
    Set-Cluster -Cluster $Object -HAEnabled:$Desired -Confirm:$false -ErrorAction Stop
```
