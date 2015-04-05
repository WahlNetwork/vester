########################################################################################################
# Removes any VM level resource reservations and limitations
# Will fail on any service VM with a DisabledMethod preventing changes (e.g. NSX Controllers)
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
	
### Gather list of VMs
$VMs = Get-VM

### Remove the reservations and limits for each VM found
$i = 1
foreach ($VM in $VMs)
	{
	# Everyone loves progress bars, so here is a progress bar
	Write-Progress -Activity "Configuring Resource Allocation Settings" -Status $VM -PercentComplete (($i / $VMs.Count) * 100)
	
    # Find VMs with limits or reservations
    $check = Get-VMResourceConfiguration $VM
    if ($check.CpuReservationMhz -ne 0 -or $check.CpuLimitMhz -ne -1 -or $check.MemReservationMB -ne 0 -or $check.MemLimitMB -ne -1)
        {
        
        # Remove the limits and reservations
        try
            {
            Get-VMResourceConfiguration $VM | Set-VMResourceConfiguration -CpuReservationMhz 0 -CpuLimitMhz $null -MemReservationMB 0 -MemLimitMB $null -ErrorAction:Stop | Out-Null
    	    Write-Host -BackgroundColor:Black -ForegroundColor:Green "Success: Removed reservations and limits from $VM"
            }

        catch
            {
            Write-Host -BackgroundColor:Black -ForegroundColor:Red "Failure: Could not remove reservations and limits from $VM"
            }

        }

	$i++
	}

Disconnect-VIServer -Confirm:$false