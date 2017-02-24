# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1
# vSphere 6.0 Hardening Guide Guideline ID - ESXi.TransparentPageSharing-intra-enabled

# Test title, e.g. 'DNS Servers'
$Title = 'Transparent Page Share Force Salting'

# The config entry stating the desired values
[int]$Desired = $cfg.host.tpsforcesalting

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
