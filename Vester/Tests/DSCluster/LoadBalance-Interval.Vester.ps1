# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'SDRS - Load Balance Interval'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Specifies the interval where SDRS checks for storage imbalances (4 hour default)'

# The config entry stating the desired values
$Desired = $cfg.dscluster.loadbalanceinterval

# The test value's data type, to help with conversion: bool/string/int
$Type = 'int'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $Object.ExtensionData.PodStorageDrsEntry.StorageDrsConfig.PodConfig.LoadBalanceInterval
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
# ** NOTE ** I was only able to set this value if i set the SDRS Enabled value as well
[ScriptBlock]$Fix = {
    $Save = Get-ChildItem Variable: | Where-Object {$_.Value -Match "dscluster"}
    $SDRSEnabled = $Save.Value.DSCluster.sdrsautomationlevel
    # Gets the desired SDRS automation level
    if(($SDRSEnabled -eq "FullyAutomated") -or ($SDRSEnabled -eq "Manual"))
    {
	    $SDRSEnabled = $TRUE
    }
    else
    {
        $SDRSEnabled = $FALSE
    }
    $StorMgr = Get-View StorageResourceManager
    $Spec = New-Object VMware.Vim.StorageDrsConfigSpec
    $Spec.PodConfigSpec = New-Object VMware.Vim.StorageDrsPodConfigSpec
    $Spec.PodConfigSpec.LoadBalanceInterval = $Desired
    $Spec.PodConfigSpec.Enabled = $SDRSEnabled
    $StorMgr.ConfigureStorageDrsForPod($Object.ExtensionData.MoRef,$Spec,$TRUE)
}