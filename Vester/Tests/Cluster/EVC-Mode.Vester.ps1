# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'EVC Mode'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Enables Enhanced vMotion Compatibility (EVC) mode on the cluster'

# The config entry stating the desired values
$Desired = $cfg.cluster.evcmode

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
	If ($Object.EVCMode) {
		$Object.EVCMode
	}
	Else {
		# If EVC mode is not configured a null value is returned causing an error
		# Using an empty string allows the check to be performed and matches what
		# New-VesterConfig will insert in the config file if it finds a null value
		""
	}
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
	If ($Desired) {
		Set-Cluster -Cluster $Object -EVCMode:$Desired -Confirm:$false -ErrorAction Stop
	}
	Else {
		# If $Desired is "", set EVC mode to $null to turn it off
		Set-Cluster -Cluster $Object -EVCMode:$null -Confirm:$false -ErrorAction Stop
	}
}
