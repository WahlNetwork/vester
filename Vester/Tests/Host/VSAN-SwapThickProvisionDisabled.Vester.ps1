# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1
# vSphere 6.0 Hardening Guide Guideline ID - ESXi.TransparentPageSharing-intra-enabled

# Test title, e.g. 'DNS Servers'
$Title = 'vSAN Swap Thick Provision Disabled'

# Test description: How New-VesterConfig explains this value to the user
$Description = '1 (Create Thin vSwap Files), 0 (Create Traditional Thick vSwap Files) ... helps save capacity in VSAN when you do not plan to overprovision on memory in the cluster'

# The config entry stating the desired values
$Desired = $cfg.host.VSANSwapThickProvisionDisabled

# The test value's data type, to help with conversion: bool/string/int
$Type = 'int'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    (Get-AdvancedSetting -Entity $Object -Name "VSAN.SwapThickProvisionDisabled").Value
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Get-AdvancedSetting -Entity $Object -Name "VSAN.SwapThickProvisionDisabled" | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
}
