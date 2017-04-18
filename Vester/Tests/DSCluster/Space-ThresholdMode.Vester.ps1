# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'SDRS - Space Threshold Mode'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Specifies the space threshold mode (utilization or freeSpace)'

# The config entry stating the desired values
$Desired = $cfg.dscluster.spacethresholdmode

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $Object.ExtensionData.PodStorageDrsEntry.StorageDrsConfig.PodConfig.SpaceLoadBalanceConfig.SpaceThresholdMode
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
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
}