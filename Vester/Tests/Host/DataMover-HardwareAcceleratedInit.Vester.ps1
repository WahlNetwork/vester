# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'DataMover Hardware Accelerated Init'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Enable hardware accelerated VMFS data initialization (requires compliant hardware)'

# The config entry stating the desired values
$Desired = $cfg.host.DataMoverHardwareAcceleratedInit

# The test value's data type, to help with conversion: bool/string/int
$Type = 'int'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'DataMover.HardwareAcceleratedInit'
    }).Value
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'DataMover.HardwareAcceleratedInit'
        } | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
}
