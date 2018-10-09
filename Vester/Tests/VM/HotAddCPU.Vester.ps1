# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'Hot Add CPU Configuration'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Specifies the HotAdd configuration for hot plugable CPU '

# The config entry stating the desired values
$Desired = $cfg.vm.cpuhotaddenabled

# The test value's data type, to help with conversion: bool/string/int
$Type = 'bool'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
# * Note * - In order to specify a reservation: a limit must be set, or unlimited must be checked
[ScriptBlock]$Actual = {
    [int]$Object.ExtensionData.Config.CpuHotAddEnabled
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    $Object | Get-VMResourceConfiguration | Set-VMResourceConfiguration -CpuReservationMhz $Desired
}