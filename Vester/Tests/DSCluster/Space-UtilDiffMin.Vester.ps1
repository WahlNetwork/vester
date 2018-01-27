# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'SDRS - Space Utilization Difference Minimum'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Specifies the minimum space utilization difference between datastores before storage migrations are recommended (1% - 50%. Default 5%)'

# The config entry stating the desired values
$Desired = $cfg.dscluster.spaceutildiffmin

# The test value's data type, to help with conversion: bool/string/int
$Type = 'int'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $Object.ExtensionData.PodStorageDrsEntry.StorageDrsConfig.PodConfig.SpaceLoadBalanceConfig.MinSpaceUtilizationDifference
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
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
}