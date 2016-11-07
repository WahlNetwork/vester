# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called by private function Invoke-VesterTest

# Test title, e.g. 'DNS Servers'
$Title = 'CD-ROM Host Device'

# The config entry stating the desired values
[bool]$Desired = $cfg.vm.allowconnectedcdrom

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
        $Object | Set-CDDrive -NoMedia -Confirm:$false
    } Else {
        Write-Warning 'CD-ROM tests do not remediate against a desired value of $true'
    }
}
