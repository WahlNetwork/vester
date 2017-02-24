# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'DRS Automation Level'

# The config entry stating the desired values
$Desired = $cfg.cluster.drslevel

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    ($Object | Get-View).Configuration.DrsConfig.VmotionRate
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    $clusterview = Get-Cluster -Name $Object | Get-View
    $clusterspec = New-Object -TypeName VMware.Vim.ClusterConfigSpecEx
    $clusterspec.drsConfig = New-Object -TypeName VMware.Vim.ClusterDrsConfigInfo
    $clusterspec.drsConfig.vmotionRate = $Desired
    $clusterview.ReconfigureComputeResource_Task($clusterspec, $true)    
}
