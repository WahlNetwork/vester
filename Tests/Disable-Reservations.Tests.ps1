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
    # CPU reservations 
    Describe -Name 'VM Configuration: CPU Reservation' -Tags @("vm") -Fixture {
        # Variables
        . $Config
        [bool]$AllowCpuReservation    = $config.vm.allowcpureservation

        If (-not $AllowCpuReservation) {
            foreach ($VM in (Get-VM -Name $config.scope.vm)) 
            {
                It -name "$($VM.name) has no CPU reservations configured" -test {
                    [array]$value = $VM | Get-VMResourceConfiguration
                    try 
                    {
                        $value.CpuReservationMhz  | Should Be 0
                    }
                    catch 
                    {
                        if ($Remediate) 
                        {
                            Write-Warning -Message $_
                            Write-Warning -Message "Remediating $VM"

                            $value | Set-VMResourceConfiguration -CpuReservationMhz 0
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

    # Memory reservations 
    Describe -Name 'VM Configuration: Memory Reservation'-Tag @("vm") -Fixture {
        # Variables
        . $Config
        [bool]$AllowMemoryReservation = $config.vm.AllowMemoryReservation

        If (-not $AllowMemoryReservation) {
            foreach ($VM in (Get-VM -Name $config.scope.vm)) 
            {
                It -name "$($VM.name) has no memory reservations configured" -test {
                    [array]$value = $VM | Get-VMResourceConfiguration
                    try 
                    {
                        $value.MemReservationMB  | Should Be 0
                    }
                    catch 
                    {
                        if ($Remediate) 
                        {
                            Write-Warning -Message $_
                            Write-Warning -Message "Remediating $VM"

                            $value | Set-VMResourceConfiguration -MemReservationMB 0
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
