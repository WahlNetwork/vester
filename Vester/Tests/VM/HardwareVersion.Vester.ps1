# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'VM Hardware Version'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Specifies the hardware version configuration for a VM'

# The config entry stating the desired values
$Desired = $cfg.vm.vmhardwareversion

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    if (!$Desired)
	{
		Write-Output "vmx-13"
    }
    else 
    {
		$MinimumVersion = $Desired.Split("-")[1]
		$VMsHardwareVersion = Get-VM -Name $Object

		# If a Hardwareversion lower than the desired minimu version is found
		if (($VMsHardwareVersion.ExtensionData.Config.Version).Split("-")[1] -lt $Desired.Split("-")[1])
		{
            		[string]$Object.ExtensionData.Config.Version  
		}
		# If the Hardwareversion violation is in desired state
		# output $Desired so the test will succeed
		else
		{
			$Desired
		}
    }
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    $Object | Set-Vm -Version $Desired
}
