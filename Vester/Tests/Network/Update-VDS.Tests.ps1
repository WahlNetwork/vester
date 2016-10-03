#requires -Modules Pester, VMware.VimAutomation.Core, VMware.VimAutomation.Vds

[CmdletBinding(SupportsShouldProcess = $true, 
               ConfirmImpact = 'Medium')]
Param(
    # Optionally fix all config drift that is discovered. Defaults to false (off)
    [switch]$Remediate = $false,

    # Optionally define a different config file to use. Defaults to Vester\Configs\Config.ps1
    [Hashtable]$Cfg,

    # VIserver Object
    [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl]$VIServer
)

Process {
    # Tests
    Describe -Name 'Network Configuration: VDS Settings' -Tags @('network','vds') -Fixture {
        # Variables
        . $Config
        [string]$linkproto = $cfg.vds.linkproto
        [string]$linkoperation = $cfg.vds.linkoperation
        [int]$mtu = $cfg.vds.mtu

        foreach ($vds in (Get-VDSwitch -Name $cfg.scope.vds -Server $VIServer)) 
        {
            It -name "$($vds.name) VDS Link Protocol" -test {
                $value = $vds.LinkDiscoveryProtocol
                try 
                {
                    $value | Should Be $linkproto
                }
                catch 
                {
                    if ($Remediate)
                    {
                        Write-Warning -Message $_
                        # TODO: Update ShouldProcess with useful info
                        if ($PSCmdlet.ShouldProcess("Target", "Operation"))
                        {
                            Write-Warning -Message "Remediating $vds"
                            Set-VDSwitch $vds -LinkDiscoveryProtocol $linkproto -Confirm:$false -ErrorAction Stop
                        }
                    }
                    else 
                    {
                        throw $_
                    }
                }
            }
            It -name "$($vds.name) VDS Link Operation" -test {
                $value = $vds.LinkDiscoveryProtocolOperation
                try 
                {
                    $value | Should Be $linkoperation
                }
                catch 
                {
                    if ($Remediate)
                    {
                        Write-Warning -Message $_
                        # TODO: Update ShouldProcess with useful info
                        if ($PSCmdlet.ShouldProcess("Target", "Operation"))
                        {
                            Write-Warning -Message "Remediating $vds"
                            Set-VDSwitch $vds -LinkDiscoveryProtocolOperation $linkoperation -Confirm:$false -ErrorAction Stop
                        }
                    }
                    else 
                    {
                        throw $_
                    }
                }
            }
            It -name "$($vds.name) VDS MTU Size" -test {
                $value = $vds.Mtu
                try 
                {
                    $value | Should Be $mtu
                }
                catch 
                {
                    if ($Remediate)
                    {
                        Write-Warning -Message $_
                        # TODO: Update ShouldProcess with useful info
                        if ($PSCmdlet.ShouldProcess("Target", "Operation"))
                        {
                            Write-Warning -Message "Remediating $vds"
                            Set-VDSwitch $vds -Mtu $mtu -Confirm:$false -ErrorAction Stop
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
