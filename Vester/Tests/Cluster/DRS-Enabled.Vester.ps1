# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'DRS State'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'On/off switch for Distributed Resource Scheduler (DRS) on the cluster'

# The config entry stating the desired values
$Desired = $cfg.cluster.drsenable

# The test value's data type, to help with conversion: bool/string/int
$Type = 'bool'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $Object.DRSEnabled
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Set-Cluster -Cluster $Object -DRSEnabled:$Desired -Confirm:$false -ErrorAction Stop
}
