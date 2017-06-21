# SDRS - IOLatencyThresholdMillisecond
Specify the IOLatencyThresholdMillisecond setting of a datastore cluster
## Discovery Code
```powershell
    $Object.IOLatencyThresholdMillisecond
```

## Remediation Code
```powershell
    $Save = Get-ChildItem Variable: | Where-Object {$_.Value -Match "dscluster"}
    $ReservableIopsThreshold = $Save.Value.DSCluster.ioresiopsthreshold
    $ReservablePercentThreshold = $Save.Value.DSCluster.iorespercentthreshold
    $ReservableThresholdMode = $Save.Value.DSCluster.ioresthresholdmode
    Set-DatastoreCluster -DatastoreCluster $Object -IOLatencyThresholdMillisecond $Desired -Confirm:$FALSE -ErrorAction Stop

    # Sets ReservablePercentThreshold and ReservableThresholdMode as the above setting will reset it
    $StorMgr = Get-View StorageResourceManager
    $Spec = New-Object VMware.Vim.StorageDrsConfigSpec
    $Spec.PodConfigSpec = New-Object VMware.Vim.StorageDrsPodConfigSpec
    $Spec.PodConfigSpec.IoLoadBalanceConfig = New-Object VMware.Vim.StorageDrsIoLoadBalanceConfig
    $Spec.PodConfigSpec.IoLoadBalanceConfig.ReservablePercentThreshold = $ReservablePercentThreshold
    $Spec.PodConfigSpec.IoLoadBalanceConfig.ReservableIopsThreshold = $ReservableIopsThreshold
    $Spec.PodConfigSpec.IoLoadBalanceConfig.ReservableThresholdMode = $ReservableThresholdMode
    $StorMgr.ConfigureStorageDrsForPod($Object.ExtensionData.MoRef,$Spec,$TRUE)
```
