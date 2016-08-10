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
    . $Config
    [bool]$allowcpulimit    = $config.vm.allowcpulimit
    [bool]$allowmemorylimit = $config.vm.allowmemorylimit

    # Tests
    # CPU Limits 
    If (-not $allowcpulimit) {
        Describe -Name 'VM Configuration: CPU Limit' -Fixture {
            . $Config

            foreach ($VM in (Get-VM -Name $config.scope.vm)) 
            {
                It -name "$($VM.name) has no CPU limits configured" -test {
                    [array]$value = $VM | Get-VMResourceConfiguration
                    try 
                    {
                        $value.CpuLimitMhz  | Should Be -1
                    }
                    catch 
                    {
                        if ($Remediate) 
                        {
                            Write-Warning -Message $_
                            Write-Warning -Message "Remediating $VM"

                            $value | Set-VMResourceConfiguration -CpuLimitMhz $null
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

    # Memory Limits 
    If (-not $allowmemorylimit) {
        Describe -Name 'VM Configuration: Memory Limit' -Fixture {
            . $Config

            foreach ($VM in (Get-VM -Name $config.scope.vm)) 
            {
                It -name "$($VM.name) has no memory limits configured" -test {
                    [array]$value = $VM | Get-VMResourceConfiguration
                    try 
                    {
                        $value.MemLimitMB  | Should Be -1
                    }
                    catch 
                    {
                        if ($Remediate) 
                        {
                            Write-Warning -Message $_
                            Write-Warning -Message "Remediating $VM"

                            $value | Set-VMResourceConfiguration -MemLimitMB $null
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
}