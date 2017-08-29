# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'HA Failover Level'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Number of physical host failures tolerated, from 1 to 4'

# The config entry stating the desired values
$Desired = $cfg.cluster.HAFailoverLevel

# The test value's data type, to help with conversion: bool/string/int
$Type = 'int'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $Object.HAFailoverLevel
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Set-Cluster -Cluster $Object -HAFailoverLevel $Desired -Confirm:$false -ErrorAction Stop
}
