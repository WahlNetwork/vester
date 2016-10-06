#requires -Modules Pester, VMware.VimAutomation.Core, VMware.VimAutomation.Vds

[CmdletBinding()]
Param(
    # Optionally fix all config drift that is discovered. Defaults to false (off)
    [switch]$Remediate = $false,

    # Optionally define a different config file to use. Defaults to Vester\Configs\Config.ps1
    [string]$Config = (Split-Path $PSScriptRoot) + '\Configs\Config.ps1'
)

Process {
    # Tests
    Describe -Name 'Network Configuration: VDS Settings' -Tags @('network','vds') -Fixture {
        # Variables
        . $Config
        [string]$linkproto = $config.vds.linkproto
        [string]$linkoperation = $config.vds.linkoperation
        [int]$mtu = $config.vds.mtu
        $uplinkNames = $config.vds.uplinkNames

        foreach ($vds in (Get-VDSwitch -Name $config.scope.vds)) 
        {
            It -name "$($vds.name) VDS Link Protocol" -test {
                $value = $vds.LinkDiscoveryProtocol
                try 
                {
                    $value | Should Be $linkproto
                }
                catch 
                {
                    if ($Remediate)
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating $vds"
                        Set-VDSwitch $vds -LinkDiscoveryProtocol $linkproto -Confirm:$false -ErrorAction Stop
                    }
                    else 
                    {
                        throw $_
                    }
                }
            }
            It -name "$($vds.name) VDS Link Operation" -test {
                $value = $vds.LinkDiscoveryProtocolOperation
                try 
                {
                    $value | Should Be $linkoperation
                }
                catch 
                {
                    if ($Remediate)
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating $vds"
                        Set-VDSwitch $vds -LinkDiscoveryProtocolOperation $linkoperation -Confirm:$false -ErrorAction Stop
                    }
                    else 
                    {
                        throw $_
                    }
                }
            }
            It -name "$($vds.name) VDS MTU Size" -test {
                $value = $vds.Mtu
                try 
                {
                    $value | Should Be $mtu
                }
                catch 
                {
                    if ($Remediate)
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating $vds"
                        Set-VDSwitch $vds -Mtu $mtu -Confirm:$false -ErrorAction Stop
                    }
                    else 
                    {
                        throw $_
                    }
                }
            }
            IT -name "$($vds.name) VDS Uplink Port Name" -test {
                [array]$value = $vds.ExtensionData.Config.UplinkPortPolicy.UplinkPortName
                try 
                {
                    Compare-Object -ReferenceObject $uplinkNames -DifferenceObject $value | Should Be $null
                }
                catch 
                {
                    if ($Remediate)
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating $vds"
                        
                        $sw = Get-VDSwitch -Name $($vds.Name)
                        $spec = New-Object VMware.Vim.VMwareDVSConfigSpec
                        $spec.configVersion = $sw.ExtensionData.Config.ConfigVersion
                        $spec.uplinkPortPolicy = New-Object VMware.Vim.DVSNameArrayUplinkPortPolicy
                        $spec.uplinkPortPolicy.uplinkPortName = $uplinkNames 
                        $sw.ExtensionData.ReconfigureDvs($spec) 

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