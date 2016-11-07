# Test title, e.g. 'DNS Servers'
$Title = 'DNS Search Domains'

# The config entry stating the desired values
$Desired = $cfg.host.searchdomains

# The command(s) to pull the actual value for comparison
$Actual = {
    (Get-VMHostNetwork -VMHost $Object).SearchDomain
}

# The command(s) to match the environment to the config
$Fix = {
    Get-VMHostNetwork -VMHost $Object | Set-VMHostNetwork -SearchDomain $Desired -ErrorAction Stop
}
