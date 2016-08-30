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
    Describe -Name 'Cluster Configuration: HA Settings' -Tags @("vcenter","cluster") -Fixture {
        # Variables
        . $Config
        [bool]$haenable = $config.cluster.haenable

        foreach ($cluster in (Get-Cluster -Name $config.scope.cluster)) 
        {
            It -name "$($cluster.name) Cluster HA State" -test {
                $value = $cluster.HAEnabled
                try 
                {
                    $value | Should Be $haenable
                }
                catch 
                {
                    if ($Remediate)
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating $cluster"
                        Set-Cluster -Cluster $cluster -HAEnabled:$haenable -Confirm:$false -ErrorAction Stop
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