# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1
# vSphere 6.0 Hardening Guide Guideline ID - VM.restrict-host-info

# Test title, e.g. 'DNS Servers'
$Title = 'Tools - VM Host Info Access'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Control access to host information from guests'

# The config entry stating the desired values
$Desired = $cfg.vm.toolshostinfoaccess

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'tools.guestlib.enableHostInfo'}).Value
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    if ((Get-AdvancedSetting -Entity $Object -Name 'tools.guestlib.enableHostInfo') -eq $null) {
        New-AdvancedSetting -Entity $Object -Name 'tools.guestlib.enableHostInfo' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'tools.guestlib.enableHostInfo'
            } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
}