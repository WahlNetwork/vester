# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'SDRS Default VM Affinity'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Specifies whether to keep VMDKs together by default or not'

# The config entry stating the desired values
$Desired = $cfg.dscluster.sdrsvmaffinity

# The test value's data type, to help with conversion: bool/string/int
$Type = 'bool'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    (Get-DatastoreCluster $Object).ExtensionData.PodStorageDrsEntry.StorageDrsConfig.PodConfig.DefaultIntraVMAffinity
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    $StorMgr = Get-View StorageResourceManager
    $Spec = New-Object VMware.Vim.StorageDrsConfigSpec
    $Spec.PodConfigSpec = New-Object VMware.Vim.StorageDrsPodConfigSpec
    $Spec.PodConfigSpec.DefaultIntraVmAffinity = $Desired
    $StorMgr.ConfigureStorageDrsForPod($Object.ExtensionData.MoRef, $Spec, $TRUE)
}
