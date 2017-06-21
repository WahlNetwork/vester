# SDRS - FreeSpace Threshold GB
Specifies the freeSpace threshold in GBs. SDRS makes storage recommendations if the free space on one or more of the datastores falls below the specified threshold
## Discovery Code
```powershell
    $Object.ExtensionData.PodStorageDrsEntry.StorageDrsConfig.PodConfig.SpaceLoadBalanceConfig.FreeSpaceThresholdGB
```

## Remediation Code
```powershell
    $Save = Get-ChildItem Variable: | Where-Object {$_.Value -Match "dscluster"}
    $SpaceThresholdMode = $Save.Value.DSCluster.spacethresholdmode
    $SpaceUtilDiffMin = $Save.Value.DSCluster.spaceutildiffmin
    $SpaceUtilizationThreshold = $Save.Value.DSCluster.spaceutilizationthresholdpercent

    $StorMgr = Get-View StorageResourceManager
    $Spec = New-Object VMware.Vim.StorageDrsConfigSpec
    $Spec.PodConfigSpec = New-Object VMware.Vim.StorageDrsPodConfigSpec
    $Spec.PodConfigSpec.SpaceLoadBalanceConfig = New-Object VMware.Vim.StorageDrsSpaceLoadBalanceConfig
    $Spec.PodConfigSpec.SpaceLoadBalanceConfig.FreeSpaceThresholdGB = $Desired
    $Spec.PodConfigSpec.SpaceLoadBalanceConfig.SpaceThresholdMode = "freeSpace"
    $StorMgr.ConfigureStorageDrsForPod($Object.ExtensionData.MoRef,$Spec,$TRUE)

    # if it was on "utilization", set it back
    if($SpaceThresholdMode -eq "utilization")
    {
	    $StorMgr = Get-View StorageResourceManager
	    $Spec = New-Object VMware.Vim.StorageDrsConfigSpec
	    $Spec.PodConfigSpec = New-Object VMware.Vim.StorageDrsPodConfigSpec
	    $Spec.PodConfigSpec.SpaceLoadBalanceConfig = New-Object VMware.Vim.StorageDrsSpaceLoadBalanceConfig
        $Spec.PodConfigSpec.SpaceLoadBalanceConfig.MinSpaceUtilizationDifference = $SpaceUtilDiffMin
	    $Spec.PodConfigSpec.SpaceLoadBalanceConfig.SpaceUtilizationThreshold = $SpaceUtilizationThreshold
	    $Spec.PodConfigSpec.SpaceLoadBalanceConfig.SpaceThresholdMode = $SpaceThresholdMode
	    $StorMgr.ConfigureStorageDrsForPod($Object.ExtensionData.MoRef,$Spec,$TRUE)
    }
```
