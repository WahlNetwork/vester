# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'DNS Search Domains'

# The config entry stating the desired values
if($cfg.host.searchdomains){
    $Desired = $cfg.host.searchdomains
}

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    (Get-VMHostNetwork -VMHost $Object).SearchDomain
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Get-VMHostNetwork -VMHost $Object | Set-VMHostNetwork -SearchDomain $Desired -ErrorAction Stop
}
