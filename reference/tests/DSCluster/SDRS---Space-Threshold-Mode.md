# SDRS - Space Threshold Mode
Specifies the space threshold mode (utilization or freeSpace)
## Discovery Code
```powershell
    $Object.ExtensionData.PodStorageDrsEntry.StorageDrsConfig.PodConfig.SpaceLoadBalanceConfig.SpaceThresholdMode
```

## Remediation Code
```powershell
    $Save = Get-ChildItem Variable: | Where-Object {$_.Value -Match "dscluster"}
    $FreeSpaceThresholdGB = $Save.Value.DSCluster.spacefreethresholdgb
    $SpaceUtilDiffMin = $Save.Value.DSCluster.spaceutildiffmin
    $SpaceUtilizationThreshold = $Save.Value.DSCluster.spaceutilizationthresholdpercent

    $StorMgr = Get-View StorageResourceManager
    $Spec = New-Object VMware.Vim.StorageDrsConfigSpec
    $Spec.PodConfigSpec = New-Object VMware.Vim.StorageDrsPodConfigSpec
    $Spec.PodConfigSpec.SpaceLoadBalanceConfig = New-Object VMware.Vim.StorageDrsSpaceLoadBalanceConfig
    $Spec.PodConfigSpec.SpaceLoadBalanceConfig.SpaceThresholdMode = $Desired
    if($Desired -eq "utilization")
    {
        $Spec.PodConfigSpec.SpaceLoadBalanceConfig.MinSpaceUtilizationDifference = $SpaceUtilDiffMin
	    $Spec.PodConfigSpec.SpaceLoadBalanceConfig.SpaceUtilizationThreshold = $SpaceUtilizationThreshold
    }
    elseif($Desired -eq "freeSpace")
    {
	    $Spec.PodConfigSpec.SpaceLoadBalanceConfig.FreeSpaceThresholdGB = $FreeSpaceThresholdGB
    }
    $StorMgr.ConfigureStorageDrsForPod($Object.ExtensionData.MoRef,$Spec,$TRUE)
```
