########################################################################################################
# Sets the syslog server value for your ESXi hosts
# You can pass along an array of strings for multiple remote syslog servers
########################################################################################################

# Pull in vars
$vars = (Get-Item $PSScriptRoot).Parent.FullName + "\vars.ps1"
Invoke-Expression ($vars -replace ' ', '` ')

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
    try
        {
        Set-VMHostSysLogServer -VMHost $Server -SysLogServer $global:esxsyslog -ErrorAction Stop | Out-Null
        (Get-EsxCli -VMHost $Server).system.syslog.reload() | Out-Null
        Write-Host -BackgroundColor:Black -ForegroundColor:Green "Success: $Server is now using $global:esxsyslog"
        }
    catch
        {
        Write-Host -BackgroundColor:Black -ForegroundColor:Green "Failure: $Server could not be configured"
        }


	$i++
	}

Disconnect-VIServer -Confirm:$false