# SDRS - Space Utilization Difference Minimum
Specifies the minimum space utilization difference between datastores before storage migrations are recommended (1% - 50%. Default 5%)
## Discovery Code
```powershell
    $Object.ExtensionData.PodStorageDrsEntry.StorageDrsConfig.PodConfig.SpaceLoadBalanceConfig.MinSpaceUtilizationDifference
```

## Remediation Code
```powershell
    $Save = Get-ChildItem Variable: | Where-Object {$_.Value -Match "dscluster"}
    $FreeSpaceThresholdGB = $Save.Value.DSCluster.spacefreethresholdgb
    $SpaceUtilizationThreshold = $Save.Value.DSCluster.spaceutilizationthresholdpercent
    $SpaceThresholdMode = $Save.Value.DSCluster.spacethresholdmode

    $StorMgr = Get-View StorageResourceManager
    $Spec = New-Object VMware.Vim.StorageDrsConfigSpec
    $Spec.PodConfigSpec = New-Object VMware.Vim.StorageDrsPodConfigSpec
    $Spec.PodConfigSpec.SpaceLoadBalanceConfig = New-Object VMware.Vim.StorageDrsSpaceLoadBalanceConfig
    $Spec.PodConfigSpec.SpaceLoadBalanceConfig.MinSpaceUtilizationDifference = $Desired
    $Spec.PodConfigSpec.SpaceLoadBalanceConfig.SpaceThresholdMode = "utilization"
    $Spec.PodConfigSpec.SpaceLoadBalanceConfig.SpaceUtilizationThreshold = $SpaceUtilizationThreshold
    $StorMgr.ConfigureStorageDrsForPod($Object.ExtensionData.MoRef,$Spec,$TRUE)

    # If the SpaceThresholdMode was "freeSpace", set it back
    if($SpaceThresholdMode -eq "freeSpace")
    {
        $StorMgr = Get-View StorageResourceManager
        $Spec = New-Object VMware.Vim.StorageDrsConfigSpec
        $Spec.PodConfigSpec = New-Object VMware.Vim.StorageDrsPodConfigSpec
        $Spec.PodConfigSpec.SpaceLoadBalanceConfig = New-Object VMware.Vim.StorageDrsSpaceLoadBalanceConfig
        $Spec.PodConfigSpec.SpaceLoadBalanceConfig.SpaceThresholdMode = "freeSpace"
        $Spec.PodConfigSpec.SpaceLoadBalanceConfig.FreeSpaceThresholdGB = $FreeSpaceThresholdGB
        $StorMgr.ConfigureStorageDrsForPod($Object.ExtensionData.MoRef,$Spec,$TRUE)	
    }
```
