# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1
# vSphere 6.0 Hardening Guide Guideline ID - ESXi.set-password-policies

# Test title, e.g. 'DNS Servers'
$Title = 'Password Policy'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'pam_passwdqc Password Policy. Default = retry=3 min=disabled,disabled,disabled,7,7'

# Test recommendation: Follows VMware's Best Practices, Hardening Guides where applicable, or Default Values
# Called by Get-VesterTest
$Recommendation = 'Site Specific'

# The config entry stating the desired values
$Desired = $cfg.host.passwordpolicy

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'Security.PasswordQualityControl'
        }).Value
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'Security.PasswordQualityControl'
    } | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
}
