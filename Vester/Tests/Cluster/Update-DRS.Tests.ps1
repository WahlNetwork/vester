#requires -Modules Pester, VMware.VimAutomation.Core

[CmdletBinding(SupportsShouldProcess = $true, 
               ConfirmImpact = 'Medium')]
Param(
    # Optionally fix all config drift that is discovered. Defaults to false (off)
    [switch]$Remediate = $false,

    # $Cfg hastable imported in Invoke-Vester
    [Hashtable]$Cfg,

    # VIserver Object
    [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl]$VIServer
)

Process {
    # Tests
    Describe -Name 'Cluster Configuration: DRS Settings' -Tags @("vcenter","cluster") -Fixture {
        # Variables
        [string]$drsmode = $cfg.cluster.drsmode
        [int]$drslevel = $cfg.cluster.drslevel

        foreach ($cluster in (Get-Datacenter -Name $cfg.scope.datacenter -Server $VIServer | Get-Cluster -Name $cfg.scope.cluster)) 
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
                        if ($PSCmdlet.ShouldProcess("vCenter '$($cfg.vcenter.vc)' - Cluster '$cluster'", "Set DRS mode to '$drsmode'"))
                        {
                            Write-Warning -Message "Remediating $cluster"
                            Set-Cluster -Cluster $cluster -DrsAutomationLevel:$drsmode -Confirm:$false -ErrorAction Stop
                        }
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
                        if ($PSCmdlet.ShouldProcess("vCenter '$($cfg.vcenter.vc)' - Cluster '$cluster'", "Set DRS level to '$drslevel'"))
                        {
                            Write-Warning -Message "Remediating $cluster"
                            $clusterview = Get-Cluster -Name $cluster | Get-View
                            $clusterspec = New-Object -TypeName VMware.Vim.ClusterConfigSpecEx
                            $clusterspec.drsConfig = New-Object -TypeName VMware.Vim.ClusterDrsConfigInfo
                            $clusterspec.drsConfig.vmotionRate = $drslevel
                            $clusterview.ReconfigureComputeResource_Task($clusterspec, $true)
                        }
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