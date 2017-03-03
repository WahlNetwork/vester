# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'CPU Limits Test'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Optionally disallow VMs from specifying a CPU limit'

# The config entry stating the desired values
$Desired = $cfg.vm.allowcpulimit

# The test value's data type, to help with conversion: bool/string/int
$Type = 'bool'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    If (($Object | Get-VMResourceConfiguration).CpuLimitMhz -eq -1) {$false} 
    Else {$true}
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    If ($Desired -eq $false) {
        $Object | Get-VMResourceConfiguration | Set-VMResourceConfiguration -CpuLimitMhz $null
    } Else {
        Write-Warning 'CPU tests do not remediate against a desired value of $true'
    }
}
