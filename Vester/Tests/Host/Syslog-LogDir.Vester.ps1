# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'Syslog Dir'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'ESXi can be configured to store log files on an in-memory file system.'

# The config entry stating the desired values
$Desired = $cfg.host.syslogdir

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    ($Object | Get-AdvancedSetting -Name Syslog.global.logDir).Value
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
	$Object | Get-AdvancedSetting -Name Syslog.global.logDir | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
}
