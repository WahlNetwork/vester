# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1
# vSphere 6.0 Hardening Guide Guideline ID - ESXi.verify-acceptance-level-accepted

# Test title, e.g. 'DNS Servers'
$Title = 'Image Profile and VIB Acceptance Level'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'VMwareCertified, VMwareAccepted, PartnerSupported (default), CommunitySupported'

# The config entry stating the desired values
$Desired = $cfg.host.vibacceptancelevel

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    (Get-EsxCli -VMHost $Object -v2).software.acceptance.get.Invoke()
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    (Get-EsxCli -VMHost $Object -v2).software.acceptance.set.Invoke(@{"level" = $Desired})
}
