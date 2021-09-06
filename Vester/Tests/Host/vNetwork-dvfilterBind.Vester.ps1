# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'Audit use of dvfilter network APIs'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'If you are using a product that makes use of this API then verify that the host has been configured correctly.'

# The config entry stating the desired values
$Desired = $cfg.host.verifydvfilterbind

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    ($Object | Get-AdvancedSetting -Name Net.DVFilterBindIpAddress).Value
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
	$Object | Get-AdvancedSetting -Name Net.DVFilterBindIpAddress | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
}
