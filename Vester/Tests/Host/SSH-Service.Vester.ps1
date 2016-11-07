# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called by private function Invoke-VesterTest

# Test title, e.g. 'DNS Servers'
$Title = 'SSH Service State'

# The config entry stating the desired values
$Desired = $cfg.host.sshenable

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    ($Object | Get-VMHostService | Where-Object -FilterScript {
        $_.Key -eq 'TSM-SSH'
    }).Running
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    if ($Desired -eq $true) 
    {
        Start-VMHostService -HostService ($Object |
            Get-VMHostService |
            Where-Object -FilterScript {
                $_.Key -eq 'TSM-SSH'
        }) -ErrorAction Stop
    }
    if ($Desired -eq $false) 
    {
        Stop-VMHostService -HostService ($Object |
            Get-VMHostService |
            Where-Object -FilterScript {
                $_.Key -eq 'TSM-SSH'
        }) -ErrorAction Stop
    }
}
