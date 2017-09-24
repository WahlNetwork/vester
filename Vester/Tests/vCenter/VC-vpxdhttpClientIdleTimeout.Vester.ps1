# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'vpxd.httpClientIdleTimeout'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Http Client Pool Idle Timeout'

# The config entry stating the desired values
$Desired = $cfg.vcenter.vpxdhttpClientIdleTimeout

# The test value's data type, to help with conversion: bool/string/int
$Type = 'Int32'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    (Get-AdvancedSetting -Entity $Object -Name "vpxd.httpClientIdleTimeout").Value
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and  to set the correct value
[ScriptBlock]$Fix = {
    Get-AdvancedSetting -Entity $Object -Name "vpxd.httpClientIdleTimeout" |
        Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
}
