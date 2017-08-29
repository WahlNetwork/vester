# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'HA AdmissionControl AutoComputePercentages'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Enables HA AC policy automatic calculation of CPU/Memory for percentage-based AC'

# The config entry stating the desired values
$Desired = $cfg.cluster.haacautocomputepercentages

# The test value's data type, to help with conversion: bool/string/int
$Type = 'bool'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $Object.ExtensionData.Configuration.DasConfig.AdmissionControlPolicy.AutoComputePercentages
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    #Thanks to http://vniklas.djungeln.se/2012/01/19/powercli-function-to-set-ha-admission-control-policy-in-percent/ for guidance
    $spec = New-Object VMware.Vim.ClusterConfigSpec
    $spec.DasConfig = $Object.ExtensionData.Configuration.DasConfig
    $spec.DasConfig.AdmissionControlPolicy.AutoComputePercentages = $Desired
    ($Object | get-view).ReconfigureCluster_Task($spec, $true)
}
