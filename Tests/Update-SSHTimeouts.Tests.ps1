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
    Describe -Name 'Host Configuration: SSH Timeouts' -Tags @("host")-Fixture {
        # Variables
        . $Config
        [int]$sshtimeout = $config.host.sshtimeout
        [int]$sshinteractivetimeout = $config.host.sshinteractivetimeout

        foreach ($server in (Get-VMHost -Name $config.scope.host)) 
        {
            It -name "$($server.name) Host SSH Timeout" -test {
                $value = Get-AdvancedSetting -Entity $server | Where-Object -FilterScript {
                    $_.Name -eq 'UserVars.ESXIShellTimeout'
                }
                try
                {
                    $value.value | Should be $sshtimeout
                }
                catch
                {
                    if ($Remediate)
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating $server"
                        (Get-AdvancedSetting -Entity $server |
                            Where-Object -FilterScript {
                                $_.Name -eq 'UserVars.ESXIShellTimeout'
                            } |
                        Set-AdvancedSetting -Value $sshtimeout -confirm:$false -ErrorAction Stop)
                    }
                    else
                    {
                        throw $_
                    }
                }
            }
            It -name "$($server.name) Host Interactive SSH Timeout" -test {
                $value = Get-AdvancedSetting -Entity $server | Where-Object -FilterScript {
                    $_.Name -eq 'UserVars.ESXIShellInteractiveTimeout'
                }
                try
                {
                    $value.value | Should be $sshinteractivetimeout
                }
                catch
                {
                    if ($Remediate)
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating $server"
                        (Get-AdvancedSetting -Entity $server |
                            Where-Object -FilterScript {
                                $_.Name -eq 'UserVars.ESXIShellInteractiveTimeout'
                            } |
                        Set-AdvancedSetting -Value $sshtimeout -confirm:$false -ErrorAction Stop)
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
