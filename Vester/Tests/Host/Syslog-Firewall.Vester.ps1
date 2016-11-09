# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'Syslog Firewall'

# The config entry stating the desired values
[bool]$Desired = $cfg.host.esxsyslogfirewallexception

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    ($Object | Get-VMHostFirewallException -name syslog).Enabled
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    $Object | Get-VMHostFirewallException -name syslog | Set-VMHostFirewallException -Enabled $Desired -ErrorAction Stop
}
