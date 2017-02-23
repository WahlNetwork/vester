# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1
# vSphere 6.0 Hardening Guide Guideline ID - vCenter.verify-nfc-ssl

# Test title, e.g. 'DNS Servers'
$Title = 'Network File Copy - Use SSL'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'On/Off switch for enabling SSL for Network File Copy. Default is True, however the key does not exist'

# The config entry stating the desired values
$Desired = $cfg.vcenter.nfcusessl

# The test value's data type, to help with conversion: bool/string/int
$Type = 'bool'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    (Get-AdvancedSetting -Entity $Object -Name config.nfc.useSSL).Value
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    if ((Get-AdvancedSetting -Entity $Object -Name config.nfc.useSSL) -eq $null) {
        New-AdvancedSetting -Entity $Object -Name config.nfc.useSSL -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'config.nfc.useSSL'
            } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
}
