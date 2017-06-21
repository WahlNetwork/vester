# VDS Link Discovery Operation Protocol
Set the link discovery protocol operataion for the VDS (Advertise, Listen, Both, and Disabled)
## Discovery Code
```powershell
    $Object.LinkDiscoveryProtocolOperation
```

## Remediation Code
```powershell
    Set-VDSwitch $Object -LinkDiscoveryProtocolOperation $Desired -Confirm:$FALSE -ErrorAction Stop
```
