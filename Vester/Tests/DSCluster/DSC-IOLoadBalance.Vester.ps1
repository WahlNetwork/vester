# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'DatastoreCluster - IOLoadBalanceEnabled'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Enable/Disable IOLoadBalanceEnabled on a datastorecluster'

# The config entry stating the desired values
$Desired = $cfg.dscluster.ioloadbalanceenabled

# The test value's data type, to help with conversion: bool/string/int
$Type = 'boolean'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $Object.IOLoadBalanceEnabled
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Set-DatastoreCluster -DatastoreCluster $Object -IOLoadBalanceEnabled $Desired -Confirm:$FALSE -ErrorAction Stop
}