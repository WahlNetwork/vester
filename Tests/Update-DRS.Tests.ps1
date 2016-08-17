#requires -Modules Pester, VMware.VimAutomation.Core

[CmdletBinding()]
Param(
    # Optionally fix all config drift that is discovered. Defaults to false (off)
    [switch]$Remediate = $false,

    # Optionally define a different config file to use. Defaults to Vester\Configs\Config.ps1
    [string]$Config = (Split-Path $PSScriptRoot) + '\Configs\Config.ps1'
)

Process {
    # Tests
    Describe -Name 'Cluster Configuration: DRS Settings' -Tags @("vcenter","cluster") -Fixture {
        # Variables
        . $Config
        [string]$drsmode = $config.cluster.drsmode
        [int]$drslevel = $config.cluster.drslevel

        foreach ($cluster in (Get-Cluster -Name $config.scope.cluster)) 
        {
            It -name "$($cluster.name) Cluster DRS Mode" -test {
                $value = (Get-Cluster $cluster).DrsAutomationLevel
                try 
                {
                    $value | Should Be $drsmode
                }
                catch 
                {
                    if ($Remediate)
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating $cluster"
                        Set-Cluster -Cluster $cluster -DrsAutomationLevel:$drsmode -Confirm:$false -ErrorAction Stop
                    }
                    else 
                    {
                        throw $_
                    }
                }
            }
            It -name "$($cluster.name) Cluster DRS Automation Level" -test {
                $value = (Get-Cluster $cluster | Get-View).Configuration.DrsConfig.VmotionRate
                try 
                {
                    $value | Should Be $drslevel
                }
                catch 
                {
                    if ($Remediate) 
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating $cluster"
                        $clusterview = Get-Cluster -Name $cluster | Get-View
                        $clusterspec = New-Object -TypeName VMware.Vim.ClusterConfigSpecEx
                        $clusterspec.drsConfig = New-Object -TypeName VMware.Vim.ClusterDrsConfigInfo
                        $clusterspec.drsConfig.vmotionRate = $drslevel
                        $clusterview.ReconfigureComputeResource_Task($clusterspec, $true)
                    }
                    else 
                    {
                        throw $_
                    }
                }
            }
        }
    }
}