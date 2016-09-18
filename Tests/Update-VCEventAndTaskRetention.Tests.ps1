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
    Describe -Name 'vCenter Configuration: Task and Event Retention' -Tags @("vCenter") -Fixture {
        # Variables
        . $Config
        [Int]$EventMaxAge = $config.vcenter.EventMaxAge
        [Bool]$EventMaxAgeEnabled = $config.vcenter.EventMaxAgeEnabled
        [Int]$TaskMaxAge = $config.vcenter.TaskMaxAge
        [bool]$TaskMaxAgeEnabled = $Config.vcenter.TaskMaxAgeEnabled

        foreach ($VCServer in ($config.vcenter.vc)) 
        {
        $VCRetention = Get-AdvancedSetting -Entity $VCServer -Name event.maxAge,event.maxAgeEnabled,task.maxAge,task.maxAgeEnabled

            It -name "$($VCServer) Event Max Age" -test {
                $value = $VCRetention[0].value
                try 
                {
                    $value | Should Be $EventMaxAge
                }
                catch 
                {
                    if ($Remediate) 
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating Event Max Age on $($VCServer)"
                        Get-AdvancedSetting -Entity $VCServer -Name event.MaxAge | Set-AdvancedSetting -Value $EventMaxAge -Confirm:$false -ErrorAction Stop
                    }
                    else 
                    {
                        throw $_
                    }
                }
            }

            It -name "$($VCServer) Event Max Age Enabled" -test {
                $value = $VCRetention[1].value
                try 
                {
                    $value | Should Be $EventMaxAgeEnabled
                }
                catch 
                {
                    if ($Remediate) 
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating Event Max Age Enabled Setting on $($VCServer)"
                        Get-AdvancedSetting -Entity $VCServer -Name event.MaxAgeEnabled | Set-AdvancedSetting -Value $EventMaxAgeEnabled -Confirm:$false -ErrorAction Stop
                    }
                    else 
                    {
                        throw $_
                    }
                }
            }

            It -name "$($VCServer) Task Max Age" -test {
                $value = $VCRetention[2].value
                try 
                {
                    $value | Should Be $TaskMaxAge
                }
                catch 
                {
                    if ($Remediate) 
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating Task Max Age on $($VCServer)"
                        Get-AdvancedSetting -Entity $VCServer -Name task.MaxAge | Set-AdvancedSetting -Value $taskMaxAge -Confirm:$false -ErrorAction Stop
                    }
                    else 
                    {
                        throw $_
                    }
                }
            }

            It -name "$($VCServer) Task Max Age Enabled" -test {
                $value = $VCRetention[3].value
                try 
                {
                    $value | Should Be $TaskMaxAgeEnabled
                }
                catch 
                {
                    if ($Remediate) 
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating Task Max Age Enabled Setting on $($VCServer)"
                        Get-AdvancedSetting -Entity $VCServer -Name Task.MaxAgeEnabled | Set-AdvancedSetting -Value $TaskMaxAgeEnabled -Confirm:$false -ErrorAction Stop
                    }
                    else 
                    {
                        throw $_
                    }
                }
            }
        }#End Foreach
    }#End Describe
}
