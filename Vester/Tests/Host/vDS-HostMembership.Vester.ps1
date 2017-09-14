# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'vDS Membership'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'vDS(es) that the ESXi host should use.'

# The config entry stating the desired values
$Desired = $cfg.host.vdswitch

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string[]'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
	(Get-VDSwitch -VMHost $Object).name
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
	write-warning "VDSwitch Memership remediation is not yet implemented, please resolve manually for host $($object.name)"
	# # Add missing vdswitches
	# $currentSwitches = (Get-VDSwitch -VMHost $Object).name | sort
	# foreach ($vdswitchStr in $cfg.host.vdswitch){
		# if (!($currentSwitches -contains $vdswitchStr)){
			# if ($vdswitch = get-vdswitch $vdswitchStr -erroraction stop){
				# Add-VDSwitchVMHost -VMHost $Object -VDSwitch $vdswitch -erroraction stop
			# }
		# }
	# }
	# # Remove excessive vdswitches
}
