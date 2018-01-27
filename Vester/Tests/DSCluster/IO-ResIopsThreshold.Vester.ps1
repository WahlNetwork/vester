# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'SDRS - IO Load Balanced Reservable Iops Threshold'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Specifies the total IOPS reservation where SDRS will make storage migration recommendations (50% - 60% of worst case peak performance)'

# The config entry stating the desired values
$Desired = $cfg.dscluster.ioresiopsthreshold

# The test value's data type, to help with conversion: bool/string/int
$Type = 'int'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $Object.ExtensionData.PodStorageDrsEntry.StorageDrsConfig.PodConfig.IOLoadBalanceConfig.ReservableIopsThreshold
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
# ** NOTE ** THe ReservableIopsThreshold setting can only get set when also settings ReservableThresholdMode to "manual"
[ScriptBlock]$Fix = {
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
}