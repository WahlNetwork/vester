# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'CD-ROM Host Device'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Optionally disallow VMs from using the host CD-ROM drive'

# The config entry stating the desired values
$Desired = $cfg.vm.allowconnectedcdrom

# The test value's data type, to help with conversion: bool/string/int
$Type = 'bool'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    If (($Object | Get-CDDrive).HostDevice -eq $null) {$false}
    Else {$true}
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    If ($Desired -eq $false) {
        $Object | Get-CDDrive | Set-CDDrive -NoMedia -Confirm:$false
    } Else {
        Write-Warning 'CD-ROM tests do not remediate against a desired value of $true'
    }
}
