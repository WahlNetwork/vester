# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'DRS Max vCPUs per Core'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'The CPU over-commitment ratio, e.g. 2:1. This is the default CPU Over-Commitment setting in the vSphere Client (HTML5). For the vSphere Web Client (Flash/Flex) see "MaxVcpusPerClusterPct"'

# The config entry stating the desired values
$Desired = $cfg.cluster.drsmaxvcpuspercore

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
	(Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'MaxVcpusPerCore'}).Value
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    if ((Get-AdvancedSetting -Entity $Object -Name 'MaxVcpusPerCore') -eq $null) {
        New-AdvancedSetting -Entity $Object -Type 'ClusterDRS' -Name 'MaxVcpusPerCore' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'MaxVcpusPerCore'
            } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
}
