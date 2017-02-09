# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1
# vSphere 6.0 Hardening Guide Guideline ID - VM.disable-disk-shrinking-wiper

# Test title, e.g. 'DNS Servers'
$Title = 'Tools Disk Wiper Disable'

# The config entry stating the desired values
$Desired = $cfg.vm.toolsdiskWiperdisable

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    If (((Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'isolation.tools.diskWiper.disable'
    }).Value) -eq $true) {$true}
    Else {$false}
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    if ((Get-AdvancedSetting -Entity $Object -Name 'isolation.tools.diskWiper.disable') -eq $null) {
        New-AdvancedSEtting -Entity $Object -Name 'isolation.tools.diskWiper.disable' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'isolation.tools.diskWiper.disable'
            } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
}
