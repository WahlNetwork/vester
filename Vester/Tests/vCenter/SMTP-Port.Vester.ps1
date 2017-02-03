# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'SMTP Port'

# The config entry stating the desired values
if($cfg.vcenter.smtpport){
    [int]$Desired = $cfg.vcenter.smtpport
}

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    (Get-AdvancedSetting -Entity $Object -Name mail.smtp.port).Value
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    Get-AdvancedSetting -Entity $Object -Name mail.smtp.port |
        Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
}
