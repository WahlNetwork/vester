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
    # Variables
    Invoke-Expression -Command (Get-Item -Path $Config)
    # [bool]$sshenable = $global:config.host.sshenable
    # [int]$sshwarn = $global:config.host.sshwarn
    Describe -Name "vCenter Roles" -Fixture {
        Foreach ($Role in $global:config.roles.Present) {
            it -name "Role: $Role" -test { 
                {Get-VIRole -name $role } | Should Not Throw  
                
            }
        }

    }

    
        # Tests
    Describe -Name "vCenter Role : $role" -Fixture {
        foreach ( $role in $global:config.Roles.Present){
            It -name "vCenter Role $Role state" -test {
               $roleinfo = Get-VIRole -name $role -ErrorAction SilentlyContinue 
               $roleinfo | should not BeNullOrEmpty
            #    {Get-VIRole -name $role } | Should Not Throw  
            }
        }
    }
}
            <#
            try {
                $value
            }

            }
            
            foreach ($server in (Get-VMHost -Name $global:config.scope.host)) 
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
            } #>
