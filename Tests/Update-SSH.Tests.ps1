#requires -Modules Pester
#requires -Modules VMware.VimAutomation.Core


[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Remediation toggle')]
    [ValidateNotNullorEmpty()]
    [switch]$Remediate,
    [Parameter(Mandatory = $true,Position = 1,HelpMessage = 'Path to the configuration file')]
    [ValidateNotNullorEmpty()]
    [string]$Config
)

Process {
    # Tests
    Describe -Name 'Host Configuration: SSH Server' -Tags @("host")-Fixture {
        # Variables
        . $Config
        [bool]$sshenable = $config.host.sshenable
        [int]$sshwarn = $config.host.sshwarn

        foreach ($server in (Get-VMHost -Name $config.scope.host)) 
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
                        Write-Warning -Message "Remediating $server"
                        (Get-AdvancedSetting -Entity $server |
                            Where-Object -FilterScript {
                                $_.Name -eq 'UserVars.SuppressShellWarning'
                            } |
                        Set-AdvancedSetting -Value $sshwarn -Confirm:$false -ErrorAction Stop)
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
