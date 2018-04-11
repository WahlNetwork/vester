# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'Authentication Domain'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Domain the host is joined to for authentication'

# The config entry stating the desired values
$Desired = $cfg.host.authdomain

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    (Get-VMHostAuthentication -VMHost $Object).Domain
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Write-Warning "$Title - Remediation not implemented!"
}
