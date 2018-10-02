# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'DRS Max vCPUs per Cluster Percent'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'The CPU over-commitment percent, e.g. 200%. This is the default CPU Over-Commitment setting in the vSphere Web Client (Flash/Flex). For the vSphere Client (HTML5) see "MaxVcpusPerClusterPct"'

# The config entry stating the desired values
$Desired = $cfg.cluster.drsmaxvcpusperclusterpct

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
	(Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'MaxVcpusPerClusterPct'}).Value
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    if ((Get-AdvancedSetting -Entity $Object -Name 'MaxVcpusPerClusterPct') -eq $null) {
        New-AdvancedSetting -Entity $Object -Type 'ClusterDRS' -Name 'MaxVcpusPerClusterPct' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'MaxVcpusPerClusterPct'
            } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
}
