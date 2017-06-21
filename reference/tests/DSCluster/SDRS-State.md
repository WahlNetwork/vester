# SDRS State
Specifies the Storage DRS automation level for the datastore cluster. This parameter accepts Disabled, Manual, and FullyAutomated values
## Discovery Code
```powershell
    $Object.SdrsAutomationLevel
```

## Remediation Code
```powershell
    Set-DatastoreCluster -DatastoreCluster $Object -SdrsAutomationLevel $Desired -Confirm:$FALSE -ErrorAction Stop
```
