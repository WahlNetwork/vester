# SDRS - IO Load Balanced Threshold Mode
Specifies the reservation threshold specification to use (automated or manual)
## Discovery Code
```powershell
    $Object.ExtensionData.PodStorageDrsEntry.StorageDrsConfig.PodConfig.IOLoadBalanceConfig.ReservableThresholdMode
```

## Remediation Code
```powershell
    $Save = Get-ChildItem Variable: | Where-Object {$_.Value -Match "dscluster"}
    $ReservableIopsThreshold = $Save.Value.DSCluster.ioresiopsthreshold
    $ReservablePercentThreshold = $Save.Value.DSCluster.iorespercentthreshold

    $StorMgr = Get-View StorageResourceManager
    $Spec = New-Object VMware.Vim.StorageDrsConfigSpec
    $Spec.PodConfigSpec = New-Object VMware.Vim.StorageDrsPodConfigSpec
    $Spec.PodConfigSpec.IoLoadBalanceConfig = New-Object VMware.Vim.StorageDrsIoLoadBalanceConfig
    $Spec.PodConfigSpec.IoLoadBalanceConfig.ReservableThresholdMode = $Desired
    $Spec.PodConfigSpec.IoLoadBalanceConfig.ReservablePercentThreshold = $ReservablePercentThreshold
    if($Desired -eq "manual")
    {
        $Spec.PodConfigSpec.IoLoadBalanceConfig.ReservableIopsThreshold = $ReservableIopsThreshold
    }
    $StorMgr.ConfigureStorageDrsForPod($Object.ExtensionData.MoRef,$Spec,$TRUE)
```
