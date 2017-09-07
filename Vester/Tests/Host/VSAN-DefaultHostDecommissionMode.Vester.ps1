# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'vSAN Default Host Decommission Mode'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'The default host decommission Mode for a given node'

# The config entry stating the desired values
$Desired = $cfg.host.VSANDefaultHostDecommissionMode

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    (Get-AdvancedSetting -Entity $Object -Name "VSAN.DefaultHostDecommissionMode").Value
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Get-AdvancedSetting -Entity $Object -Name "VSAN.DefaultHostDecommissionMode" |
        Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
}
