########################################################################################################
# Removes CDDrive media from the VMs
# No toggle at this point; either run it or don't :)
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
	
### Gather list of VMs
$VMs = Get-VM | Where {$_.PowerState -eq "PoweredOn"}

### Comb through the VMs and disconnect CDs
$i = 1
foreach ($VM in $VMs)
	{
	# Everyone loves progress bars, so here is a progress bar
	Write-Progress -Activity "Removing Media" -Status $VM -PercentComplete (($i / $VMs.Count) * 100)

    Get-CDDrive $VM | Where {$_.ConnectionState -eq "true" -or $_.IsoPath -ne $null} | Set-CDDrive -NoMedia -Confirm:$false | Out-Null
	
	$i++
	}

Disconnect-VIServer -Confirm:$false