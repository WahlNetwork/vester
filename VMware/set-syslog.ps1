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

### Update Syslog server info on the ESXi hosts in $vmhosts
$i = 1
foreach ($Server in $VMHosts)
	{
	# Everyone loves progress bars, so here is a progress bar
	Write-Progress -Activity "Configuring Syslog Settings" -Status $Server -PercentComplete (($i / $VMHosts.Count) * 100)
	
    # Set the syslog server properties
    Set-VMHostSysLogServer -VMHost $Server -SysLogServer $global:esxsyslog

	$i++
	}

Disconnect-VIServer -Confirm:$false