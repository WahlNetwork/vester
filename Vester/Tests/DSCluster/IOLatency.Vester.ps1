# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'IO Latency Threshold Millisecond'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Specifies the maximum I/O latency in milliseconds allowed before Storage DRS is triggered for the datastore cluster'

# The config entry stating the desired values
$Desired = $cfg.dscluster.iolatencythresholdmillisecond

# The test value's data type, to help with conversion: bool/string/int
$Type = 'int'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $Object.IOLatencyThresholdMillisecond
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Set-DatastoreCluster -DatastoreCluster $Object -IOLatencyThresholdMillisecond $Desired -Confirm:$FALSE -ErrorAction Stop
}
