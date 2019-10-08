# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'DPM State'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Enables Distributed Power Managment (DPM) on the cluster'

# The config entry stating the desired values
$Desired = $cfg.cluster.dpmenable

# The test value's data type, to help with conversion: bool/string/int
$Type = 'bool'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $Object.ExtensionData.ConfigurationEx.DpmConfigInfo.Enabled
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
	$spec = New-Object VMware.Vim.ClusterConfigSpecEx
	$spec.dpmConfig = New-Object VMware.Vim.ClusterDpmConfigInfo
	$spec.dpmConfig.enabled = $Desired
	(Get-View -VIObject $Object).ReconfigureComputeResource_Task($spec, $true)
}
