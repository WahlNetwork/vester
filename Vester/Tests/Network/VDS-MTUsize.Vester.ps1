# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'VDS MTU Size'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Set the MTU size for the VDS'

# The config entry stating the desired values
$Desired = $cfg.vds.mtu

# The test value's data type, to help with conversion: bool/string/int
$Type = 'int'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $Object.MTU
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Set-VDSwitch $Object -Mtu $Desired -Confirm:$FALSE -ErrorAction Stop
}
