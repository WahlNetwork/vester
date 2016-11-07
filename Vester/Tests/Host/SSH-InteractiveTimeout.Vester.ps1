# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called by private function Invoke-VesterTest

# Test title, e.g. 'DNS Servers'
$Title = 'SSH Interactive Timeout'

# The config entry stating the desired values
$Desired = $cfg.host.sshinteractivetimeout

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'UserVars.ESXIShellInteractiveTimeout'
    }).Value
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'UserVars.ESXIShellInteractiveTimeout'
        } | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
}
