# VDS MTU Size
Set the MTU size for the VDS
## Discovery Code
```powershell
    $Object.MTU
```

## Remediation Code
```powershell
    Set-VDSwitch $Object -Mtu $Desired -Confirm:$FALSE -ErrorAction Stop
```
