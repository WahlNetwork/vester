# VDS Teaming and Failover HealthCheck State
On/Off switch to control the VDS Teaming and Failover HealthCheck setting
## Discovery Code
```powershell
    ($Object.ExtensionData.Config.HealthCheckConfig.Enable)[1]
```

## Remediation Code
```powershell
    Get-View -VIObject $object.name | 
    foreach {$_.UpdateDVSHealthCheckConfig(@((New-Object Vmware.Vim.VMwareDVSTeamingHealthCheckConfig -property @{enable=$Desired})))}
```
