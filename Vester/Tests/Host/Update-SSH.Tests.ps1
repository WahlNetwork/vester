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
    Describe -Name 'Host Configuration: SSH Server' -Tags @("host")-Fixture {
        # Variables
        [bool]$sshenable = $cfg.host.sshenable
        [int]$sshwarn = $cfg.host.sshwarn

        foreach ($server in (Get-Datacenter -name $cfg.scope.datacenter -Server $VIServer | Get-Cluster -Name $cfg.scope.cluster | Get-VMHost -Name $cfg.scope.host)) 
        {
            It -name "$($server.name) Host SSH Service State" -test {
                $value = $server |
                Get-VMHostService |
                Where-Object -FilterScript {
                    $_.Key -eq 'TSM-SSH'
                }
                try 
                {
                    $value.Running | Should Be $sshenable
                }
                catch 
                {
                    if ($Remediate) 
                    {
                        Write-Warning -Message $_
                        # TODO: Update ShouldProcess with useful info
                        if ($PSCmdlet.ShouldProcess("Target", "Operation"))
                        {
                            Write-Warning -Message "Remediating $server"
                            if ($sshenable -eq $true) 
                            {
                                Start-VMHostService -HostService ($server |
                                    Get-VMHostService |
                                    Where-Object -FilterScript {
                                        $_.Key -eq 'TSM-SSH'
                                }) -ErrorAction Stop
                            }
                            if ($sshenable -eq $false) 
                            {
                                Stop-VMHostService -HostService ($server |
                                    Get-VMHostService |
                                    Where-Object -FilterScript {
                                        $_.Key -eq 'TSM-SSH'
                                }) -ErrorAction Stop
                            }
                        }
                    }
                    else 
                    {
                        throw $_
                    }
                }
            }
            It -name "$($server.name) Host SSH Warning State" -test {
                $value = Get-AdvancedSetting -Entity $server | Where-Object -FilterScript {
                    $_.Name -eq 'UserVars.SuppressShellWarning'
                }
                try 
                {
                    $value.Value | Should Be $sshwarn
                }
                catch 
                {
                    if ($Remediate) 
                    {
                        Write-Warning -Message $_
                        # TODO: Update ShouldProcess with useful info
                        if ($PSCmdlet.ShouldProcess("Target", "Operation"))
                        {
                            Write-Warning -Message "Remediating $server"
                            (Get-AdvancedSetting -Entity $server |
                                Where-Object -FilterScript {
                                    $_.Name -eq 'UserVars.SuppressShellWarning'
                                } |
                            Set-AdvancedSetting -Value $sshwarn -Confirm:$false -ErrorAction Stop)
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
