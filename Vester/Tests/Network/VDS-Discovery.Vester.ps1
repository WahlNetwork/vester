# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called by private function Invoke-VesterTest

# Test title, e.g. 'DNS Servers'
$Title = 'VDS Link Protocol'

# The config entry stating the desired values
[string]$Desired = $cfg.vds.linkproto

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $Object.LinkDiscoveryProtocol
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Set-VDSwitch $Object -LinkDiscoveryProtocol $Desired -Confirm:$false -ErrorAction Stop
}
