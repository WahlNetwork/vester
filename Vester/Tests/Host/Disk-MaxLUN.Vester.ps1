# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1
# ESXi host Disk.MaxLUN advanced setting.
# Some customer environments relied on lower legacy default value to avoid PDL errors with certain vendor SAN management LUNs exposed at a higher number.
# See https://kb.vmware.com/kb/1998

# Test title, e.g. 'DNS Servers'
$Title = 'Disk MaxLUN'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Highest LUN ID available to ESXi host.  Above this number will be ignored.'

# The config entry stating the desired values
$Desired = $cfg.host.diskmaxlun

# The test value's data type, to help with conversion: bool/string/int
$Type = 'int'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'Disk.MaxLUN'
    }).Value
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'Disk.MaxLUN'
        } | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
}
