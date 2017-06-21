# SDRS - IO Load ImBalanced Threshold
Specifies the I/O load imbalance level where SDRS will make storage migration recommendations (1 - 100. Default 5)
## Discovery Code
```powershell
    $Object.ExtensionData.PodStorageDrsEntry.StorageDrsConfig.PodConfig.IOLoadBalanceConfig.IoLoadImbalanceThreshold
```

## Remediation Code
```powershell
    $Save = Get-ChildItem Variable: | Where-Object {$_.Value -Match "dscluster"}
    $ReservableIopsThreshold = $Save.Value.DSCluster.ioresiopsthreshold
    $ReservablePercentThreshold = $Save.Value.DSCluster.iorespercentthreshold
    $ReservableThresholdMode = $Save.Value.DSCluster.ioresthresholdmode

    $StorMgr = Get-View StorageResourceManager
    $Spec = New-Object VMware.Vim.StorageDrsConfigSpec
    $Spec.PodConfigSpec = New-Object VMware.Vim.StorageDrsPodConfigSpec
    $Spec.PodConfigSpec.IoLoadBalanceConfig = New-Object VMware.Vim.StorageDrsIoLoadBalanceConfig
    $Spec.PodConfigSpec.IoLoadBalanceConfig.IoLoadImbalanceThreshold = $Desired
    $Spec.PodConfigSpec.IoLoadBalanceConfig.ReservablePercentThreshold = $ReservablePercentThreshold
    $Spec.PodConfigSpec.IoLoadBalanceConfig.ReservableThresholdMode = $ReservableThresholdMode
    $Spec.PodConfigSpec.IoLoadBalanceConfig.ReservableIopsThreshold = $ReservableIopsThreshold
    $StorMgr.ConfigureStorageDrsForPod($Object.ExtensionData.MoRef,$Spec,$TRUE)
```
