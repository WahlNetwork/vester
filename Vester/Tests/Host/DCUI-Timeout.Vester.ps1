# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1
# vSphere 6.0 Hardening Guide Guideline ID - ESXi.set-dcui-timeout

# Test title, e.g. 'DNS Servers'
$Title = 'DCUI Timeout'

# Test description: How New-VesterConfig explains this value to the user
$Description = '0 (off) number of seconds before the DCUI timeout occurs'

# Test recommendation: Follows VMware's Best Practices, Hardening Guides where applicable, or Default Values
# Called by Get-VesterTest
$Recommendation = 600

# The config entry stating the desired values
$Desired = $cfg.host.dcuitimeout

# The test value's data type, to help with conversion: bool/string/int
$Type = 'int'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'UserVars.DcuiTimeOut'
        }).Value
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'UserVars.DcuiTimeOut'
    } | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
}
