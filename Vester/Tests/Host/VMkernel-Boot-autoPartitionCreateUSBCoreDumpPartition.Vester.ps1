# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'VMkernel Boot autoPartitionCreateUSBCoreDumpPartition'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Enable/Disable auto-partitioning of core dump partition for USB boot devices. Requires that autoPartition is set to TRUE as well.
VMkernel.Boot.autoPartitionDiskDumpPartitionSize	2560	Disk dump partition size in MB that gets '

# The config entry stating the desired values
$Desired = $cfg.host.VMkernelBootautoPartitionCreateUSBCoreDumpPartition

# The test value's data type, to help with conversion: bool/string/int
$Type = 'bool'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'VMkernel.Boot.autoPartitionCreateUSBCoreDumpPartition'
    }).Value
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'VMkernel.Boot.autoPartitionCreateUSBCoreDumpPartition'
        } | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
}
