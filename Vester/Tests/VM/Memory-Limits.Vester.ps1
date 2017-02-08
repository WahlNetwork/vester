# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'Memory Limits Test'

# The config entry stating the desired values
[bool]$Desired = $cfg.vm.allowmemorylimit

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    If (($Object | Get-VMResourceConfiguration).MemLimitMB -eq -1) {$false} 
    Else {$true}
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    If ($Desired -eq $false) {
        $Object | Get-VMResourceConfiguration | Set-VMResourceConfiguration -MemLimitMB $null
    } Else {
        Write-Warning 'Memory tests do not remediate against a desired value of $true'
    }
}
