# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'SDRS - FreeSpace Threshold GB'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Specifies the freeSpace threshold in GBs. SDRS makes storage recommendations if the free space on one or more of the datastores falls below the specified threshold'

# The config entry stating the desired values
$Desired = $cfg.dscluster.spacefreethresholdgb

# The test value's data type, to help with conversion: bool/string/int
$Type = 'int'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $Object.ExtensionData.PodStorageDrsEntry.StorageDrsConfig.PodConfig.SpaceLoadBalanceConfig.FreeSpaceThresholdGB
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
# ** NOTE ** You can only set FreeSpaceThresholdGB when SpaceThresholdMode is "freeSpace"
[ScriptBlock]$Fix = {
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
}