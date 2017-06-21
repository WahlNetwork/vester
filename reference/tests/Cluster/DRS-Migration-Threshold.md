# DRS Migration Threshold
Migration Threshold [int](1-5) for Distributed Resource Scheduler (DRS) on the cluster
## Discovery Code
```powershell
    ($Object | Get-View).Configuration.DrsConfig.VmotionRate
```

## Remediation Code
```powershell
    $clusterview = Get-Cluster -Name $Object | Get-View
    $clusterspec = New-Object -TypeName VMware.Vim.ClusterConfigSpecEx
    $clusterspec.drsConfig = New-Object -TypeName VMware.Vim.ClusterDrsConfigInfo
    $clusterspec.drsConfig.vmotionRate = $Desired
    $clusterview.ReconfigureComputeResource_Task($clusterspec, $true)    
```
