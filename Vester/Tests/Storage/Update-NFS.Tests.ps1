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
    Describe -Name 'Host Configuration: NFS Advanced Configuration' -Tag @("host","storage","nfs") -Fixture {
        # Variables
        [Hashtable]$nfsadvconfig = $cfg.nfsadvconfig
        $compare = @()
        $nfsadvconfig.Values | ForEach-Object -Process {
            $compare += $_
        }
        foreach ($server in (Get-Datacenter -name $cfg.scope.datacenter -Server $VIServer | Get-Cluster -Name $cfg.scope.cluster | Get-VMHost -Name $cfg.scope.host).name) 
        {
            $hostadvcfg = Get-AdvancedSetting -Entity $server
            $hostadvsettings = @{}
            foreach ($setting in $hostadvcfg) { 
                $sname = $setting.name
                $svalue = $setting.value
                $hostadvsettings[$sname] = $svalue
        }
            $value =@() 
            foreach ($setting in $nfsadvconfig.Keys) {
                if ($hostadvsettings.ContainsKey($setting)){
                    $value += $hostadvsettings.$setting
                } else { 
                    #nop 
                }
            }
            It -name "$server NFS Settings" -test {
                try 
                {
                    $value | Should Be $compare
                }
                catch 
                {
                    if ($Remediate) 
                    {
                        Write-Warning -Message $_
                        if ($PSCmdlet.ShouldProcess("vCenter '$($cfg.vcenter.vc)' - Host '$server'", "NFS config settings should be '$($nfsadvconfig.Values)'"))
                        {
                            Write-Warning -Message "Remediating $server"
                            $nfsadvconfig.Keys | ForEach-Object -Process {
                                Get-AdvancedSetting -Entity $server -Name $_ | Set-AdvancedSetting -Value $nfsadvconfig.Item($_) -Confirm:$false -ErrorAction Stop
                            }
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
