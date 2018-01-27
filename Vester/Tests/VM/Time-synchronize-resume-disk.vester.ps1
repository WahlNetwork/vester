# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1
# Disabling Time Synchronization - https://kb.vmware.com/s/article/1189

# Test title, e.g. 'DNS Servers'
$Title = 'Time Synchronize Resume Disk'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'A setting of 0 disables time synchronization with the VM and ESXi host during the specified operation'

# Test recommendation: Follows VMware's Best Practices, Hardening Guides where applicable, or Default Values
# Called by Get-VesterTest
$Recommendation = 0

# The config entry stating the desired values
$Desired = $cfg.vm.timesyncresumedisk

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'time.synchronize.resume.disk'}).Value
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    if ((Get-AdvancedSetting -Entity $Object -Name 'time.synchronize.resume.disk') -eq $null) {
        New-AdvancedSetting -Entity $Object -Name 'time.synchronize.resume.disk' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'time.synchronize.resume.disk'
        } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
}