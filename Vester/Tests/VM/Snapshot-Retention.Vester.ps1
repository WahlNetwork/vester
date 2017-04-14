# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'VM Snapshot Retention'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Deletes snapshots older than the retention period'

# The config entry stating the desired values
$Desired = $cfg.vm.snapshotretention

# The test value's data type, to help with conversion: bool/string/int
$Type = 'int'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
	# If a desired retention period has not been set
	if(!$Desired)
	{
		Write-Output 999
	}
	else
	{
		$Snapshots = $Object | Get-Snapshot | Where-Object { $_.Created -lt (Get-Date).AddDays(-$Desired) }
		# If a snapshot older than the retention period is found
		# output a random number so it will trigger a test failure
		if($Snapshots)
		{
			Write-Warning "Snapshot(s) older than $Desired have been found."
			Write-Output (999 - $Desired)
		}
		# If a snapshot retention violation is not found
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
	$Object | Get-Snapshot | Where-Object { $_.Created -lt (Get-Date).AddDays(-$Desired) } | Remove-Snapshot -ErrorAction Stop -Confirm:$FALSE
}
