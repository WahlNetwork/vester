# VDS Vlan and MTU HealthCheck State
On/Off switch to control the VDS Vlan and MTU HealthCheck setting
## Discovery Code
```powershell
    ($Object.ExtensionData.Config.HealthCheckConfig.Enable)[0]
```

## Remediation Code
```powershell
    Get-View -VIObject $object.name | 
    foreach {$_.UpdateDVSHealthCheckConfig(@((New-Object Vmware.Vim.VMwareDVSVlanMtuHealthCheckConfig -property @{enable=$Desired})))}
```
