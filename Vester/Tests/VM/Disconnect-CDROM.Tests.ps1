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
    Describe -Name 'VM Configuration: CDROM status' -Tag @("vm") -Fixture {
        # Variables
        . $Config
        [bool]$allowconnectedcdrom = $cfg.vm.allowconnectedcdrom

        If (-not $allowconnectedcdrom) {
            foreach ($VM in (Get-VM -Name $cfg.scope.vm)) 
            {
                [array]$value = $VM | get-cddrive
                It -name "$($VM.name) has no CDROM connected to ISO file " -test {
                    try 
                    {
                        $value.IsoPath  | Should BeNullOrEmpty
                    }
                    catch 
                    {
                        if ($Remediate) 
                        {
                            Write-Warning -Message $_
                            # TODO: Update ShouldProcess with useful info
                            if ($PSCmdlet.ShouldProcess("Target", "Operation"))
                            {
                                Write-Warning -Message "Remediating $VM"
                                $Value | Set-CDDrive -NoMedia -Confirm:$false
                            }
                        }
                        else 
                        {
                            throw $_
                        }
                    }
                }
                It -name "$($VM.name) has no CDROM connected to Host Device" -test {
                    try 
                    {
                        $value.HostDevice  | Should BeNullOrEmpty
                    }
                    catch 
                    {
                        if ($Remediate) 
                        {
                            Write-Warning -Message $_
                            # TODO: Update ShouldProcess with useful info
                            if ($PSCmdlet.ShouldProcess("Target", "Operation"))
                            {
                                Write-Warning -Message "Remediating $VM"
                                $Value | Set-CDDrive -NoMedia -Confirm:$false
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
}
