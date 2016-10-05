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
    Describe -Name 'Host Configuration: Syslog Server' -Tags @("host") -Fixture {
        # Variables
        [array]$esxsyslog = $cfg.host.esxsyslog

        foreach ($server in (Get-Datacenter -name $cfg.scope.datacenter -Server $VIServer | Get-Cluster -Name $cfg.scope.cluster | Get-VMHost -Name $cfg.scope.host)) 
        {
            It -name "$($server.name) Host Syslog Service State" -test {
                [array]$value = Get-VMHostSysLogServer -VMHost $server
                try 
                {
                    Compare-Object -ReferenceObject $esxsyslog -DifferenceObject $value | Should Be $null
                }
                catch 
                {
                    if ($Remediate) 
                    {
                        Write-Warning -Message $_
                        if ($PSCmdlet.ShouldProcess("vCenter '$($cfg.vcenter.vc)' - Host '$server'", "Syslog target should be '$esxsyslog'"))
                        {
                            Write-Warning -Message "Remediating $server"
                            Set-VMHostSysLogServer -VMHost $server -SysLogServer $esxsyslog -ErrorAction Stop
                            (Get-EsxCli -VMHost $server).system.syslog.reload()
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
