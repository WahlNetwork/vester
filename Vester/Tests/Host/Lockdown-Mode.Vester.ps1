# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'Lockdown Mode'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Enable lockdown mode to restrict remote access.'

# The config entry stating the desired values
$Desired = $cfg.host.lockdown

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
	$myhost = $Object | Get-View
	$lockdown = Get-View $myhost.ConfigManager.HostAccessManager
	$lockdown.UpdateViewData()
	$lockdown.LockdownMode
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
	$myhost = $Object | Get-View
	$lockdown = Get-View $myhost.ConfigManager.HostAccessManager
	$lockdown.ChangeLockdownMode($Desired)
	$lockdown.UpdateViewData()
}
