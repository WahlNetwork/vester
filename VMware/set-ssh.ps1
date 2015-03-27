########################################################################################################
# Control the state of your ESXi SSH Server status, and also optionally disable the warning
# Note: I only recommend using this in lab environments, it's not a valid security practice in prod
########################################################################################################

# Pull in vars
$vars = (Get-Item $PSScriptRoot).Parent.FullName + "\vars.ps1"
Invoke-Expression ($vars)

### Import modules
Add-PSSnapin -Name VMware.VimAutomation.Core

    # Ignore self-signed SSL certificates for vCenter Server (optional)
    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -DisplayDeprecationWarnings:$false -Scope User -Confirm:$false

### Connect to vCenter
Connect-VIServer $global:vc
	
### Gather ESXi host data for future processing
$VMHosts = Get-VMHost

### Update SSH server info on the ESXi hosts in $vmhosts
$i = 1
foreach ($Server in $VMHosts)
	{
	# Everyone loves progress bars, so here is a progress bar
	Write-Progress -Activity "Configuring SSH Settings" -Status $Server -PercentComplete (($i / $VMHosts.Count) * 100)
	
    # SSH Server status    
    if ($global:sshenable -eq $true) {Start-VMHostService -HostService ($Server | Get-VMHostService | Where { $_.Key -eq “TSM-SSH” } ) | Out-Null}
    else {Stop-VMHostService -HostService ($Server | Get-VMHostService | Where { $_.Key -eq “TSM-SSH” } ) | Out-Null}
	Write-Host -BackgroundColor:Black -ForegroundColor:Green "Success: $Server SSH Running status is now" (Get-VMHostService $Server | Where { $_.Key -eq “TSM-SSH” }).Running
    
    # Disable SSH Warning (UserVars)
    Write-Host -BackgroundColor:Black -ForegroundColor:Green "Success: $Server Shell Warning Supression is set to" (Get-AdvancedSetting -Entity $Server | Where {$_.Name -eq "UserVars.SuppressShellWarning"} | Set-AdvancedSetting -Value "$global:sshwarn" -Confirm:$false).Value
	

	$i++
	}

Disconnect-VIServer -Confirm:$false