#requires -Modules Pester, VMware.VimAutomation.Core

[CmdletBinding(SupportsShouldProcess = $true, 
               ConfirmImpact = 'Medium')]
Param(
    # Optionally fix all config drift that is discovered. Defaults to false (off)
    [switch]$Remediate = $false,

    # Optionally define a different config file to use. Defaults to Vester\Configs\Config.ps1
    [string]$Config = (Split-Path $PSScriptRoot) + '\Configs\Config.ps1'
)

Process {
    # Tests
    Describe -Name 'Host Configuration: SSH Server' -Tags @("host")-Fixture {
        # Variables
        . $Config
        [bool]$sshenable = $cfg.host.sshenable
        [int]$sshwarn = $cfg.host.sshwarn

        foreach ($server in (Get-VMHost -Name $cfg.scope.host)) 
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
                        If ($sshenable -eq $true) {
                            $WhatIf1 = 'running'
                        } Else {
                            $WhatIf1 = 'stopped'
                        }
                        if ($PSCmdlet.ShouldProcess("vCenter '$($cfg.vcenter.vc)' - Host '$server'", "SSH service should be '$WhatIf1'"))
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
                        If ($sshwarn -eq 0) {
                            $WhatIf2 = 'disabled'
                        } Else {
                            $WhatIf2 = 'enabled'
                        }
                        if ($PSCmdlet.ShouldProcess("vCenter '$($cfg.vcenter.vc)' - Host '$server'", "SSH warning should be '$WhatIf2'"))
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
