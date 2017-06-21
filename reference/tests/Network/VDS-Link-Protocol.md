# VDS Link Protocol
Set the discovery mode for downstream switches (Cisco, HP, none)
## Discovery Code
```powershell
    $Object.LinkDiscoveryProtocol
```

## Remediation Code
```powershell
    Set-VDSwitch $Object -LinkDiscoveryProtocol $Desired -Confirm:$false -ErrorAction Stop
```
