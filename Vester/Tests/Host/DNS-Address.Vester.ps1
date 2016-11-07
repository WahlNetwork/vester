# Test title, e.g. 'DNS Servers'
$Title = 'DNS Servers'

# The config entry stating the desired values
$Desired = $cfg.host.esxdns

# The command(s) to pull the actual value for comparison
$Actual = {
(Get-VMHostNetwork -VMHost $Object).DnsAddress
}

# The command(s) to match the environment to the config
$Fix = {
Get-VMHostNetwork -VMHost $Object | Set-VMHostNetwork -DnsAddress $Desired -ErrorAction Stop
}
