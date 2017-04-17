# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'SDRS - IOLatencyThresholdMillisecond'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Specify the IOLatencyThresholdMillisecond setting of a datastore cluster'

# The config entry stating the desired values
$Desired = $cfg.dscluster.iolatencythresholdmillisecond

# The test value's data type, to help with conversion: bool/string/int
$Type = 'int'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $Object.IOLatencyThresholdMillisecond
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
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
}