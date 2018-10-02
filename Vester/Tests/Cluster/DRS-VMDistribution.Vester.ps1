# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'DRS VM Distribution'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'For availability, distribute a more even number of VMs across hosts.  When this option is enabled in the vSphere Client the value is "1"'

# The config entry stating the desired values
$Desired = $cfg.cluster.drsvmdistribution

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
	(Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'TryBalanceVmsPerHost'}).Value
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    if ((Get-AdvancedSetting -Entity $Object -Name 'TryBalanceVmsPerHost') -eq $null) {
        New-AdvancedSetting -Entity $Object -Type 'ClusterDRS' -Name 'TryBalanceVmsPerHost' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'TryBalanceVmsPerHost'
            } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
}
