# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'Syslog Server'

# The config entry stating the desired values
if($cfg.host.esxsyslog){
    $Desired = $cfg.host.esxsyslog
}

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    Get-VMHostSysLogServer -VMHost $Object
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Set-VMHostSysLogServer -VMHost $Object -SysLogServer $Desired -ErrorAction Stop
    (Get-EsxCli -VMHost $Object).system.syslog.reload()
}
