########################################################################################################
# Sets the DNS entries for your ESXi servers
# Can pass along multiple entries as an array of string values
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

### Update DNS server info on the ESXi hosts in $vmhosts
$i = 1
foreach ($Server in $VMHosts)
	{
	# Everyone loves progress bars, so here is a progress bar
	Write-Progress -Activity "Configuring DNS Settings" -Status $Server -PercentComplete (($i / $VMHosts.Count) * 100)
	
    # Add desired DNS value(s) to the host
    Get-VMHostNetwork $Server | Set-VMHostNetwork -DnsAddress $global:esxdns -SearchDomain $global:searchdomains | Out-Null

	# Output to console (optional)
	Write-Host -BackgroundColor:Black -ForegroundColor:Green "Success: $Server is now using DNS server(s)" (Get-VMHostNetwork $Server).DnsAddress

	$i++
	}

Disconnect-VIServer -Confirm:$false