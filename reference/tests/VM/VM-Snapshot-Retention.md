# VM Snapshot Retention
Deletes snapshots older than the retention period
## Discovery Code
```powershell
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
```

## Remediation Code
```powershell
	$Object | Get-Snapshot | Where-Object { $_.Created -lt (Get-Date).AddDays(-$Desired) } | Remove-Snapshot -ErrorAction Stop -Confirm:$FALSE
```
