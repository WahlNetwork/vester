# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1
# vSphere 6.0 Hardening Guide Guideline ID - VM.disable-unexposed-features-unity-windowcontents
# Unexposed features are items that apply to Workstation or Fusion but not vSphere
# Explicitly disabling the settings reduces potential vulnerabilities

# Test title, e.g. 'DNS Servers'
$Title = 'VMX Unity Window Contents Disable'

# The config entry stating the desired values
$Desired = $cfg.vm.vmxunitywindow

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    If (((Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'isolation.tools.unity.windowContents.disable'
    }).Value) -eq $true) {$true}
    Else {$false}
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    if ((Get-AdvancedSetting -Entity $Object -Name 'isolation.tools.unity.windowContents.disable') -eq $null) {
        New-AdvancedSetting -Entity $Object -Name 'isolation.tools.unity.windowContents.disable' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'isolation.tools.unity.windowContents.disable'
        } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
}
