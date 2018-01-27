# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1
# vSphere 6.0 Hardening Guide Guideline ID - ESXi.TransparentPageSharing-intra-enabled

# Test title, e.g. 'DNS Servers'
$Title = 'Transparent Page Share Force Salting'

# Test description: How New-VesterConfig explains this value to the user
$Description = '0 (TPS enabled) 1 (TPS enabled for VMs with same salt) 2 (No inter-VM TPS)'

# Test recommendation: Follows VMware's Best Practices, Hardening Guides where applicable, or Default Values
# Called by Get-VesterTest
$Recommendation = 2

# The config entry stating the desired values
$Desired = $cfg.host.tpsforcesalting

# The test value's data type, to help with conversion: bool/string/int
$Type = 'int'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'Mem.ShareForceSalting'
        }).Value
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'Mem.ShareForceSalting'
    } | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
}
