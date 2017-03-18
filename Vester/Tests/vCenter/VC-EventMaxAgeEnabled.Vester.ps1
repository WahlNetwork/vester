# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'EventMaxAgeEnabled'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Enables Event cleanup and enforces the max age defined in EventMaxAge'

# The config entry stating the desired values
$Desired = $cfg.vcenter.EventMaxAgeEnabled

# The test value's data type, to help with conversion: bool/string/int
$Type = 'bool'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    (Get-AdvancedSetting -Entity $Object -Name event.maxAgeEnabled).Value
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Get-AdvancedSetting -Entity $Object -Name event.maxAgeEnabled |
        Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
}
