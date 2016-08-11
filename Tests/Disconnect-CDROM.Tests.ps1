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
    Describe -Name 'VM Configuration: CDROM status' -Fixture {
        # Variables
        . $Config
        [bool]$allowconnectedcdrom = $config.vm.allowconnectedcdrom

        If (-not $allowconnectedcdrom) {
            foreach ($VM in (Get-VM -Name $config.scope.vm)) 
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
                            Write-Warning -Message "Remediating $VM"
                            $Value | Set-CDDrive -NoMedia -Confirm:$false
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
                            Write-Warning -Message "Remediating $VM"
                            $Value | Set-CDDrive -NoMedia -Confirm:$false
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
