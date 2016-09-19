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
    Describe -Name 'VM : Sync Time Settings' -Tag @("vm") -Fixture {
        # Variables
        . $Config
        [bool]$VMSyncTimeWithHost = $config.vm.VMSyncTimeWithHost
            foreach ($VM in (Get-VM -Name $config.scope.vm))
            {
                $value = get-view $VM | select name,@{N='syncTimeWithHost';E={$_.Config.Tools.syncTimeWithHost}}
                It -name "$($VM.name) VM Sync Time With Host " -test {
                    try 
                    {
                        $value.syncTimeWithHost | Should Be $VMSyncTimeWithHost
                    }
                    catch 
                    {
                        if ($Remediate) 
                        {
                            Write-Warning -Message $_
                            Write-Warning -Message "Remediating $VM"
                            $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
                            $spec.ChangeVersion = $VM.ExtensionData.Config.ChangeVersion
                            $spec.Tools = New-Object VMware.Vim.ToolsConfigInfo
                            $spec.Tools.syncTimeWithHost = $VMSyncTimeWithHost
                            $ChangeVM = Get-View -id $VM.Id
                            $ChangeVM.ReconfigVM_Task($spec)
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
