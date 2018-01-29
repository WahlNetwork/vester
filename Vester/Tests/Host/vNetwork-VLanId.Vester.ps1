# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'vNetwork VLAN ID'

# Test description: How New-VesterConfig explains this value to the user
$Description = "Specifies portgroup VLAN ID"

# The config entry stating the desired values
$Desired = $cfg.host.vnetworkvlanid

# The test value's data type, to help with conversion: bool/string/int
$Type = 'hashtable'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $ht2 = @{}
    $Object | Get-VirtualPortGroup -Standard | Foreach { $ht2[$_.Name] = $_.VLanId }
    $ht2
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
	$Desired.keys| Foreach {
		$VirtualPortGroup=$_
		$vmhost | Get-VirtualPortGroup -Standard -Name $VirtualPortGroup | Set-VirtualPortGroup -VLanId $Desired[$_]
	}
}
