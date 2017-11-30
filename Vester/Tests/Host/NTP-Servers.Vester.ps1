# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'NTP Servers'

# Test description: How New-VesterConfig explains this value to the user
$Description = "Server(s) to use for synchronizing the host's clock"

# The config entry stating the desired values
$Desired = $cfg.host.esxntp

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string[]'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    Get-VMHostNtpServer -VMHost $Object
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    # Create a HostDateTimeConfig to update the NTP servers
    $ntpConfig = New-Object -TypeName Vmware.Vim.HostNtpConfig
    $ntpConfig.Server = $Desired
    $dateTimeConfig = New-Object -TypeName Vmware.Vim.HostDateTimeConfig
    $dateTimeConfig.NtpConfig = $ntpConfig

    # Get the host's DateTimeSystem and update the config
    $vmhostView = Get-View -VIObject $Object -Property 'ConfigManager.DateTimeSystem'
    $dateTimeManager = Get-View -Id $vmhostView.ConfigManager.DateTimeSystem
    $dateTimeManager.UpdateDateTimeConfig($dateTimeConfig)

    $ntpclient = Get-VMHostService -VMHost $Object | Where-Object -FilterScript {
        $_.Key -match 'ntpd'
    }
    $ntpclient | Set-VMHostService -Policy:On -Confirm:$false -ErrorAction:Stop
    $ntpclient | Restart-VMHostService -Confirm:$false -ErrorAction:Stop
}
