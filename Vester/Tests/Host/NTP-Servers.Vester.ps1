# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'NTP Servers'

# The config entry stating the desired values
$Desired = $cfg.host.esxntp

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    Get-VMHostNtpServer -VMHost $Object
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Get-VMHostNtpServer -VMHost $Object | ForEach-Object -Process {
        Remove-VMHostNtpServer -VMHost $Object -NtpServer $_ -Confirm:$false -ErrorAction Stop
    }
    Add-VMHostNtpServer -VMHost $Object -NtpServer $Desired -ErrorAction Stop
    $ntpclient = Get-VMHostService -VMHost $Object | Where-Object -FilterScript {
        $_.Key -match 'ntpd'
    }
    $ntpclient | Set-VMHostService -Policy:On -Confirm:$false -ErrorAction:Stop
    $ntpclient | Restart-VMHostService -Confirm:$false -ErrorAction:Stop
}
