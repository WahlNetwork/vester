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
    Describe -Name 'VM : Boot Delay' -Tag @("vm") -Fixture {
        # Variables
        . $Config
        [int]$VMBootDelay = $config.vm.bootDelay

            foreach ($VM in (Get-Datacenter $config.scope.datacenter -server $config.vc.vcenter | Get-Cluster $config.scope.cluster | Get-VM $config.scope.vm))
            {
                [int]$value = ($VM | Get-View).Config.BootOptions.BootDelay
                It -name "$($VM.name) VM Boot Delay " -test {
                    try 
                    {
                        $value | Should be $VMBootDelay
                    }
                    catch 
                    {
                        if ($Remediate)
                        {
                            Write-Warning -Message $_
                            Write-Warning -Message "Remediating $VM"
                            $vmbo = New-Object VMware.Vim.VirtualMachineBootOptions
	                        $vmbo.BootDelay = $bootDelay
	                        $vmcs = New-Object VMware.Vim.VirtualMachineConfigSpec
	                        $vmcs.BootOptions = $vmbo
	                        $VM.ExtensionData.ReconfigVM($vmcs)
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
