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
    Describe -Name 'VM Configuration: Snapshot(s)' -Tag @("vm") -Fixture {
        # Variables
        . $Config
        [int]$snapretention = $config.vm.snapretention

        foreach ($VM in (Get-VM -Name $config.scope.vm)) 
        {
            It -name "$($VM.name) has no snapshot older than $snapretention day(s)" -test {
                [array]$value = $VM |
                Get-Snapshot |
                Where-Object -FilterScript {
                    $_.Created -lt (Get-Date).AddDays(-$snapretention)
                }
                try 
                {
                    $value | Should BeNullOrEmpty
                }
                catch 
                {
                    if ($Remediate) 
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating $VM"
                        Remove-Snapshot -Snapshot $value -ErrorAction Stop -Confirm:$false
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