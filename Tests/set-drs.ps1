########################################################################################################
# Sets DRS configuration values for Mode and Aggressiveness# 
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
	
### Gather cluster data for future processing
$Clusters = Get-Cluster

### Update cluster configuration across the environment
$i = 1
foreach ($Cluster in $Clusters)
	{
	# Everyone loves progress bars, so here is a progress bar
	Write-Progress -Activity "Configuring Cluster Settings" -Status $Cluster -PercentComplete (($i / $Clusters.Count) * 100)

    # DRS Mode
    Set-Cluster $Cluster -DrsAutomationLevel:$global:drsmode -Confirm:$false
    Write-Host -BackgroundColor:Black -ForegroundColor:Green "Success: $Cluster is now set to" (Get-Cluster $Cluster).DrsAutomationLevel

    # DRS Threshold (modified script from the amazing LucD)
	if ($Cluster.DrsAutomationLevel -eq "FullyAutomated")
        {
        $ClusterView = Get-Cluster -Name $Cluster | Get-View
        $ClusterSpec = New-Object VMware.Vim.ClusterConfigSpecEx
        $ClusterSpec.drsConfig = New-Object VMware.Vim.ClusterDrsConfigInfo
        $ClusterSpec.drsConfig.vmotionRate = $global:drslevel
        $ClusterView.ReconfigureComputeResource_Task($ClusterSpec, $true)
        }

	$i++
	}

Disconnect-VIServer -Confirm:$false