# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'DRS Memory Metric for Load Balancing'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Load balance based on consumed memory of vritual machines rather than active memory.  When this option is enabled in the vSphere Client the default value is "100"'

# The config entry stating the desired values
$Desired = $cfg.cluster.drsmemorymetricforlb

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
	(Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'PercentIdleMBInMemDemand'}).Value
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    if ((Get-AdvancedSetting -Entity $Object -Name 'PercentIdleMBInMemDemand') -eq $null) {
        New-AdvancedSetting -Entity $Object -Type 'ClusterDRS' -Name 'PercentIdleMBInMemDemand' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'PercentIdleMBInMemDemand'
            } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
}
