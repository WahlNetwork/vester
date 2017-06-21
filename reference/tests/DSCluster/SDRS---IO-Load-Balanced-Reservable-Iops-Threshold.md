# SDRS - IO Load Balanced Reservable Iops Threshold
Specifies the total IOPS reservation where SDRS will make storage migration recommendations (50% - 60% of worst case peak performance)
## Discovery Code
```powershell
    $Object.ExtensionData.PodStorageDrsEntry.StorageDrsConfig.PodConfig.IOLoadBalanceConfig.ReservableIopsThreshold
```

## Remediation Code
```powershell
    $Save = Get-ChildItem Variable: | Where-Object {$_.Value -Match "dscluster"}
    $ReservablePercentThreshold = $Save.Value.DSCluster.iorespercentthreshold
    $ReservableThresholdMode = $Save.Value.DSCluster.ioresthresholdmode

    $StorMgr = Get-View StorageResourceManager
    $Spec = New-Object VMware.Vim.StorageDrsConfigSpec
    $Spec.PodConfigSpec = New-Object VMware.Vim.StorageDrsPodConfigSpec
    $Spec.PodConfigSpec.IoLoadBalanceConfig = New-Object VMware.Vim.StorageDrsIoLoadBalanceConfig
    $Spec.PodConfigSpec.IoLoadBalanceConfig.ReservableIopsThreshold = $Desired
    # This must be set to manual to specify ReservableIopsThreshold
    $Spec.PodConfigSpec.IoLoadBalanceConfig.ReservableThresholdMode = "manual"
    $Spec.PodConfigSpec.IoLoadBalanceConfig.ReservablePercentThreshold = $ReservablePercentThreshold
    $StorMgr.ConfigureStorageDrsForPod($Object.ExtensionData.MoRef,$Spec,$TRUE)

    # Resets the ReservableThresholdMode back to "automated"
    if($ReservableThresholdMode -ne "manual")
    {
        $StorMgr = Get-View StorageResourceManager
        $Spec = New-Object VMware.Vim.StorageDrsConfigSpec
        $Spec.PodConfigSpec = New-Object VMware.Vim.StorageDrsPodConfigSpec
        $Spec.PodConfigSpec.IoLoadBalanceConfig = New-Object VMware.Vim.StorageDrsIoLoadBalanceConfig
        $Spec.PodConfigSpec.IoLoadBalanceConfig.ReservableThresholdMode = "automated"
        $StorMgr.ConfigureStorageDrsForPod($Object.ExtensionData.MoRef,$Spec,$TRUE)        
    }
```
