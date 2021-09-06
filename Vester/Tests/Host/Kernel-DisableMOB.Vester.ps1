# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'Disable Managed Object Browser (MOB)'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Disables (or enables) The managed object browser (MOB)'

# The config entry stating the desired values
$Desired = $cfg.host.disablemob

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    ($Object | Get-AdvancedSetting -Name Config.HostAgent.plugins.solo.enableMob).Value
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
	$Object | Get-AdvancedSetting -Name Config.HostAgent.plugins.solo.enableMob |Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
}
