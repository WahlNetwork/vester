# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'Join Domain'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Join ESXi hosts to an Active Directory (AD) domain to eliminate the need to create and maintain multiple local user accounts.'

# The config entry stating the desired values
$Desired = $cfg.host.joindomain

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    ($Object | Get-VMHostAuthentication).Domain
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    if (($Object | Get-VMHostAuthentication).Domain -ne $null){
		$Object | Get-VMHostAuthentication | Set-VMHostAuthentication -LeaveDomain -Force -Confirm:$false
	}
    $Object | Get-VMHostAuthentication | Set-VMHostAuthentication -JoinDomain -Domain $Desired -Credential (Get-Credential -Message "Please enter privileged credential for join domain $Desired") -Confirm:$false
}
