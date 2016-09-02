#requires -Modules Pester, VMware.VimAutomation.Core

[CmdletBinding()]
Param(
    # Optionally fix all config drift that is discovered. Defaults to false (off)
    [switch]$Remediate = $false,

    # Optionally define a different config file to use. Defaults to Vester\Configs\Config.ps1
    [string]$Config = (Split-Path $PSScriptRoot) + '\Configs\Config.ps1'
)

Process {
    Describe -Name 'Cluster Configuration: Advanced HA Settings' -Tags @("vcenter","cluster") -Fixture {
    # Variables
    . $Config
    [bool]$enableVMCP = $config.cluster.enableVMCP
    [string]$VmStorageProtectionForPDL = $config.cluster.VmStorageProtectionForPDL
    [string]$VmStorageProtectionForAPD = $config.cluster.VmStorageProtectionForAPD
    [int]$VmTerminateDelayForAPDSec = $config.cluster.VmTerminateDelayForAPDSec
    [string]$VmReactionOnAPDCleared = $config.cluster.VmReactionOnAPDCleared

    foreach ($cluster in (Get-Cluster -Name $config.scope.cluster)) 
    {
        It -name "$($cluster.name) Cluster VMCP State" -test {
                $value = Get-VMCPSettings -Cluster 'Test Cluster'

                try 
                {
                    $value.'VMCP Status' | Should Be $enableVMCP
                    $value.'Protection For PDL' | Should Be $VmStorageProtectionForPDL
                    $value.'Protection For APD' | Should Be $VmStorageProtectionForAPD
                    $value.'APD Timeout (Seconds)' | Should Be $VmTerminateDelayForAPDSec
                    $value.'Reaction on APD Cleared' | Should Be $VmReactionOnAPDCleared
                }
            catch 
            {
                if ($Remediate) 
                {
                    Write-Warning -Message $_
                    Write-Warning -Message "Remediating $cluster"
                    Set-VMCPSettings -cluster $Cluster -enableVMCP:$True -VmStorageProtectionForPDL $VmStorageProtectionForPDL -VmStorageProtectionForAPD $VmStorageProtectionForAPD -VmTerminateDelayForAPDSec $VmTerminateDelayForAPDSec -VmReactionOnAPDCleared $VmReactionOnAPDCleared -ErrorAction Stop
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
